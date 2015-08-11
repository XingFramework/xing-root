

module Xing::Tasks
  class Develop < Mattock::Tasklib
    DEFAULT_RELOAD_PORT = 35729
    DEFAULT_RAILS_PORT  = 3000
    DEFAULT_MOBILE_PORT = 9000
    DEFAULT_STATIC_PORT  = 9292

    default_namespace :develop

    setting :port_offset
    setting :reload_server_port, :rails_server_port, :mobile_server_port, :browser_port
    setting :manager


    def default_configuration
      @port_offset ||=
        begin
          if !ENV['PORT_OFFSET'].nil?
            ENV['PORT_OFFSET'].to_i.tap do |offset|
              puts "Shifting server ports by #{offset}"
            end
          else
            0
          end
        end

      @manager ||=
        begin
          require 'child-manager'
          require 'tmux-manager'
          if TmuxManager.available?
            TmuxPaneManager.new
          else
            ChildManager.new.tap do |mngr|
              at_exit{ mngr.kill_all }
            end
          end
        end.tap do |mgr|
          puts "Using #{mgr.class.name}"
        end
    end

    def resolve_configuration
      self.reload_server_port = DEFAULT_RELOAD_PORT + port_offset if field_unset?(:reload_server_port)
      self.rails_server_port  = DEFAULT_RAILS_PORT  + port_offset if field_unset?(:rails_server_port)
      self.mobile_server_port = DEFAULT_MOBILE_PORT + port_offset if field_unset?(:mobile_server_port)
      self.static_server_port = DEFAULT_STATIC_PORT + port_offset if field_unset?(:static_server_port)
    end

    class CleanRun < Edict::Rule
      settings :dir, :shell_cmd
      setting :env_hash

      def setup
        self.env_hash ||= {}
      end

      def action
        Bundler.with_clean_env do
          env_hash.each_pair do |name, value|
            ENV[name] = value
          end
          Dir.chdir(dir) do
            sh(*shell_cmd)
          end
        end
      end
    end

    class StartChild < Edict::Rule
      setting :manager, :label, :child_task

      def action
        manager.start_child(label, child_task)
      end
    end

    class LaunchBrowser < Edict::Rule
      def action
        fork do
          require 'net/http'
          require 'json'

          setup_time_limit = 60
          begin_time = Time.now
          begin
            test_conn = TCPSocket.new 'localhost', reload_server_port
          rescue Errno::ECONNREFUSED
            if Time.now - begin_time > setup_time_limit
              puts "Couldn't connect to test server on localhost:#{reload_server_port} after #{setup_time_limit} seconds - bailing out"
              exit 1
            else
              sleep 0.05
              retry
            end
          ensure
            test_conn.close rescue nil
          end

          started = Time.now
          max_wait = 16

          changes = {}
          while(Time.now - started < max_wait)
            begin
              changes = JSON.parse(Net::HTTP.get(URI("http://localhost:#{reload_server_port}/changed")))
            rescue Errno::ECONNREFUSED
              puts "LiveReload server abruptly stopped receiving connections. Bailing out."
              exit 2
            end

            if changes["clients"].empty?
              sleep 0.25
            else
              break
            end
          end

          if changes["clients"].empty?
            puts
            puts "No running development browsers: launching...."
            p changes

            cmds = %w{open xdg-open chrome chromium}
            cmd = nil
            begin
              cmd = cmds.shift
            end until cmd.nil? or system(%{which #{cmd}})

            if cmd.nil?
              warn "Can't find any executable to launch a browser with. (WTF?) --jdl"
            end

            sh cmd, "http://localhost:#{static_server_port}/"
          else
            puts
            puts "There's already a browser attached to the LiveReload server."
            p changes["clients"].first
          end
        end
      end
    end

    def edict_task(name, klass, &block)
      edict = klass.new do |eddie|
        copy_to(eddie)
        yield eddie if block_given?
      end
      task name do
        edict.enact
      end
    end

    def define
      in_namespace do
        desc "Launch a browser connected to a running development server"
        edict_task :launch_browser, LaunchBrowser

        edict_task :grunt_watch, StartChild do |gw|
          gw.label = "Grunt"
          gw.child_task = 'develop:service:grunt_watch'
        end

        edict_task :compass_watch, StartChild do |cw|
          cw.label = "Compass"
          cw.child_task = "develop:service:compass_watch"
        end

        edict_task :rails_server, StartChild do |rs|
          rs.label = "Rails"
          rs.child_task = 'develop:service:rails_server'
        end

        edict_task :sidekiq, StartChild do |sk|
          sk.label = "Sidekiq"
          sk.child_task = 'develop:service:sidekiq'
        end

        edict_task :static_assets, StartChild do |sa|
          sa.label = "Static"
          sa.child_task = 'develop:service:static_assets'
        end

        namespace :service do
          edict_task :grunt_watch, CleanRun do |gw|
            gw.dir = "frontend"
            gw.shell_cmd = %w{bundle exec node_modules/.bin/grunt watch:develop}
            gw.env_hash = {"CUSTOM_CONFIG_DIR" => "../web"}
          end
          task :grunt_watch => 'frontend:setup'

          edict_task :compass_watch, CleanRun do |cw|
            cw.dir = "frontend"
            cw.shell_cmd = %w{bundle exec compass watch}
          end

          edict_task :rails_server, CleanRun do |rs|
            words = %w{bundle exec rails server}
            words << "-p#{rails_server_port}"

            rs.dir = "backend"
            rs.shell_cmd = words
          end
          task :rails_server => 'backend:setup'

          edict_task :sidekiq, CleanRun do |sk|
            sk.dir = "backend"
            sk.shell_cmd = %w{bundle exec sidekiq}
          end

          edict_task :static_assets, CleanRun do |sa|
            words = %w{bundle exec rackup}
            words << "-p#{static_server_port}"
            words << "static-app.ru"

            sa.dir = "backend"
            sa.shell_cmd = words
            sa.env_hash = {"LRD_BACKEND_PORT" => "#{rails_server_port}"}
          end
        end

        task :wait do
          manager.wait_all
        end

        task :startup => [:grunt_watch, :compass_watch, :sidekiq, :static_assets, :rails_server, :launch_browser]

        task :all => [:startup, :wait]
      end
    end

  end
end
