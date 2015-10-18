require 'xing/edicts'
require 'xing/tasks/tasklib'

module Xing
  module Tasks
    class Build < Tasklib
      default_namespace :build
      setting :config_dir, "../frontend"

      def define
        in_namespace do
          task :all => ['frontend:all']

          namespace :frontend do
            edict_task :grunt_compile, Edicts::CleanRun do |gc|
              gc.dir = "frontend"
              gc.env_hash = {"CUSTOM_CONFIG_DIR" => config_dir}
              gc.shell_cmd = %w{bundle exec node_modules/.bin/grunt compile}
            end
            task :grunt_compile => ['frontend:setup']

            task :all => [:grunt_compile]
          end
        end
      end
    end
  end
end
