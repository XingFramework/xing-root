require 'xing/edicts'
require 'xing/tasks/tasklib'

module Xing
  module Tasks
    class Spec < Tasklib
      default_namespace :spec

      def define
        in_namespace do
          edict_task :grunt_ci_test, Edicts::CleanRun do |gct|
            gct.dir = "frontend"
            gct.env_hash = {'CUSTOM_CONFIG_DIR' => "../web"}
            gct.shell_cmd = %w{bundle exec node_modules/.bin/grunt ci-test}
          end
          task :grunt_ci_test => ['build:frontend:all' ]

          namespace :links do
            %w{index.html assets fonts}.each do |thing|
              edict_task thing, Edict::Command do |l|
                l.command = ["ln", "-sfn", "../../frontend/bin/#{thing}", "backend/public/#{thing}"]
              end
            end
          end

          edict_task :prepare_db, Edicts::CleanRun do |pd|
            pd.dir = "backend"
            pd.shell_cmd = %w{bundle exec rake db:test:prepare}
          end

          full_spec_edict = Edicts::CleanRun.new do |eddie|
            copy_settings_to(eddie)
            eddie.dir = "backend"
            eddie.shell_cmd = %w{bundle exec rspec}
          end
          task :full, [:spec_files] => [:check_dependencies, 'frontend:code_structure', :grunt_ci_test, 'backend:setup', :prepare_db] do |t, args|
            if args[:spec_files]
              full_spec_edict.shell_cmd.push(args[:spec_files])
            end
            full_spec_edict.enact
          end

          desc "Run all feature specs, repeating with each browser width as default"
          responsivity_edict = Edicts::CleanRun.new do |eddie|
            copy_settings_to(eddie)
            eddie.dir = "backend"
          end
          task :responsivity, [:spec_files] => ['backend:setup', :prepare_db] do |t, args|
            %w{mobile small medium desktop}.each do |size|
              responsivity_edict.shell_cmd = ["bundle", "exec", "rspec", "-o", "tmp/rspec_#{size}.txt"]
              responsivity_edict.env_hash = {'BROWSER_SIZE' => size}
              if args[:spec_files]
                responsivity_edict.shell_cmd.push(args[:spec_files])
              else
                responsivity_edict.shell_cmd.push('spec/features')
              end
              responsivity_edict.enact rescue true
            end
          end

          fast_edict = Edicts::CleanRun.new do |eddie|
            copy_settings_to(eddie)
            eddie.dir = "backend"
            eddie.shell_cmd = %w{bundle exec rspec}
          end
          task :fast, [:spec_files] => ['backend:setup', :prepare_db] do |t, args|
            if args[:spec_files]
              fast_edict.shell_cmd.push(args[:spec_files])
            else
              fast_edict.shell_cmd.push("--tag").push("~type:feature")
            end
            fast_edict.enact
          end
        end
      end
    end
  end
end
