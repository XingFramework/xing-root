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

      def resolve_configuration
        self.reload_server_port = DEFAULT_RELOAD_PORT + port_offset if field_unset?(:reload_server_port)
        self.rails_server_port  = DEFAULT_RAILS_PORT  + port_offset if field_unset?(:rails_server_port)
        self.mobile_server_port = DEFAULT_MOBILE_PORT + port_offset if field_unset?(:mobile_server_port)
        self.static_server_port = DEFAULT_STATIC_PORT + port_offset if field_unset?(:static_server_port)
      end

      def define
        in_namespace do
          desc "Launch a browser connected to a running development server"
          edict_task :launch_browser, Edict::LaunchBrowser

          edict_task :grunt_watch, Edict::StartChild do |gw|
            gw.label = "Grunt"
            gw.child_task = 'develop:service:grunt_watch'
          end

          edict_task :compass_watch, Edict::StartChild do |cw|
            cw.label = "Compass"
            cw.child_task = "develop:service:compass_watch"
          end

          edict_task :rails_server, Edict::StartChild do |rs|
            rs.label = "Rails"
            rs.child_task = 'develop:service:rails_server'
          end

          edict_task :sidekiq, Edict::StartChild do |sk|
            sk.label = "Sidekiq"
            sk.child_task = 'develop:service:sidekiq'
          end

          edict_task :static_assets, Edict::StartChild do |sa|
            sa.label = "Static"
            sa.child_task = 'develop:service:static_assets'
          end

          namespace :service do
            edict_task :grunt_watch, Edict::CleanRun do |gw|
              gw.dir = "frontend"
              gw.shell_cmd = %w{bundle exec node_modules/.bin/grunt watch:develop}
              gw.env_hash = {"CUSTOM_CONFIG_DIR" => "../web"}
            end
            task :grunt_watch => 'frontend:setup'

            edict_task :compass_watch, Edict::CleanRun do |cw|
              cw.dir = "frontend"
              cw.shell_cmd = %w{bundle exec compass watch}
            end

            edict_task :rails_server, Edict::CleanRun do |rs|
              words = %w{bundle exec rails server}
              words << "-p#{rails_server_port}"

              rs.dir = "backend"
              rs.shell_cmd = words
            end
            task :rails_server => 'backend:setup'

            edict_task :sidekiq, Edict::CleanRun do |sk|
              sk.dir = "backend"
              sk.shell_cmd = %w{bundle exec sidekiq}
            end

            edict_task :static_assets, Edict::CleanRun do |sa|
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
