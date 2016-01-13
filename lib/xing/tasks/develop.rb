require 'xing/edicts'
require 'xing/tasks/tasklib'

module Xing
  module Tasks
    class Develop < Tasklib
      DEFAULT_RELOAD_PORT = 35729
      DEFAULT_RAILS_PORT  = 3000
      DEFAULT_MOBILE_PORT = 9000
      DEFAULT_STATIC_PORT  = 9292

      default_namespace :develop

      setting :port_offset
      setting :reload_server_port
      setting :rails_server_port
      setting :mobile_server_port
      setting :static_server_port
      setting :manager
      setting :config_dir, "../frontend"

      def get_port_offset
        if !ENV['PORT_OFFSET'].nil?
          ENV['PORT_OFFSET'].to_i.tap do |offset|
            puts "Shifting server ports by #{offset}"
          end
        else
          0
        end
      end

      def choose_output_manager
        begin
          require 'xing/managers/child'
          require 'xing/managers/tmux'
          if Managers::Tmux.available?
            Managers::TmuxPane.new
          else
            ChildManager.new.tap do |mngr|
              at_exit{ mngr.kill_all }
            end
          end
        end.tap do |mgr|
          puts "Using #{mgr.class.name}"
        end
      end

      def default_configuration
        @port_offset ||= get_port_offset
        @manager ||= choose_output_manager
        super
      end

      def resolve_configuration
        super
        self.reload_server_port = DEFAULT_RELOAD_PORT + port_offset if field_unset?(:reload_server_port)
        self.rails_server_port  = DEFAULT_RAILS_PORT  + port_offset if field_unset?(:rails_server_port)
        self.mobile_server_port = DEFAULT_MOBILE_PORT + port_offset if field_unset?(:mobile_server_port)
        self.static_server_port = DEFAULT_STATIC_PORT + port_offset if field_unset?(:static_server_port)
      end

      def define
        in_namespace do
          desc "Launch a browser connected to a running development server"
          edict_task :launch_browser, Edicts::LaunchBrowser

          edict_task :grunt_watch, Edicts::StartChild do |gw|
            gw.manager = manager
            gw.label = "Grunt"
            gw.child_task = in_namespace('service:grunt_watch').first
          end

          edict_task :compass_watch, Edicts::StartChild do |cw|
            cw.manager = manager
            cw.label = "Compass"
            cw.child_task = in_namespace('service:compass_watch').first
          end

          edict_task :rails_server, Edicts::StartChild do |rs|
            rs.manager = manager
            rs.label = "Rails"
            rs.child_task = in_namespace('service:rails_server').first
          end

          edict_task :sidekiq, Edicts::StartChild do |sk|
            sk.manager = manager
            sk.label = "Sidekiq"
            sk.child_task = in_namespace('service:sidekiq').first
          end

          edict_task :static_assets, Edicts::StartChild do |sa|
            sa.manager = manager
            sa.label = "Static"
            sa.child_task = in_namespace('service:static_assets').first
          end

          namespace :service do
            edict_task :grunt_watch, Edicts::CleanRun do |gw|
              gw.dir = "frontend"
              gw.shell_cmd = %w{bundle exec node_modules/.bin/grunt delta:develop}
              gw.env_hash = {"CUSTOM_CONFIG_DIR" => config_dir}
            end
            task :grunt_watch => 'frontend:setup'

            edict_task :compass_watch, Edicts::CleanRun do |cw|
              cw.dir = "frontend"
              cw.shell_cmd = %w{bundle exec compass watch}
            end

            edict_task :rails_server, Edicts::CleanRun do |rs|
              words = %w{bundle exec rails server}
              words << "-p#{rails_server_port}" #ok

              rs.dir = "backend"
              rs.shell_cmd = words
            end
            task :rails_server => 'backend:setup'

            edict_task :sidekiq, Edicts::CleanRun do |sk|
              sk.dir = "backend"
              sk.shell_cmd = %w{bundle exec sidekiq}
            end

            edict_task :static_assets, Edicts::CleanRun do |sa|
              words = %w{bundle exec rackup}
              words << "-p#{static_server_port}" #ok
              words << "static-app.ru"

              sa.dir = "backend"
              sa.shell_cmd = words
              sa.env_hash = {
                "LRD_BACKEND_PORT" => "#{rails_server_port}", # deprecate for 1.0
                "XING_BACKEND_PORT" => "#{rails_server_port}"
              }
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
end
