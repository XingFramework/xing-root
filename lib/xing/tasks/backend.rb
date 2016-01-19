require 'xing/edicts'
require 'xing/tasks/tasklib'

module Xing
  module Tasks
    class Backend < Tasklib
      default_namespace :backend
      setting :dir, "backend"

      def define
        in_namespace do
          edict_task :bundle_install, Edicts::CleanRun do |bi|
            bi.shell_cmd = %w{bundle check || bundle install}
          end

          edict_task :check_dependencies, Edicts::CleanRun do |cd|
            cd.shell_cmd = %w{bundle exec rake dependencies:check}
          end
          task :check_dependencies => :bundle_install

          desc "Initialize database"
          edict_task :db_create, Edicts::CleanRun do |dm|
            dm.shell_cmd = %w{bundle exec rake db:create}
          end
          task :db_create => :bundle_install

          desc "Migrate database up to current"
          edict_task :db_migrate, Edicts::CleanRun do |dm|
            dm.shell_cmd = %w{bundle exec rake db:migrate}
          end
          task :db_migrate => :bundle_install

          task :setup => [:bundle_install, :db_migrate]

          edict_task :db_seed, Edicts::CleanRun do |ds|
            ds.shell_cmd = %w{bundle exec rake db:seed}
          end
          task :db_seed => :db_migrate

          desc "Precompile rails assets"
          edict_task :assets_precompile, Edicts::CleanRun do |ap|
            ap.shell_cmd = %w{bundle exec rake assets:precompile}
          end
          task :assets_precompile => [:bundle_install, :db_migrate]

          task :initialize => [:db_create, :db_seed]

          task :all => [:db_seed, :assets_precompile]
        end
      end
    end
  end
end
