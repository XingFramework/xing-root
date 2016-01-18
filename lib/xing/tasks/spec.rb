require 'xing/edicts'
require 'xing/tasks/tasklib'

module Xing
  module Edicts
    class Spec < CleanRun
      setting :spec_targets, "spec/"
      setting :shell_cmd, %w{bundle exec rspec}

      def action
        self.shell_cmd += [*spec_targets]
        super
      end
    end
  end

  module Tasks
    class Spec < Tasklib
      default_namespace :spec
      setting :config_dir, "../frontend"

      def define
        in_namespace do
          edict_task :grunt_ci_test, Edicts::CleanRun do |gct|
            gct.dir = "frontend"
            gct.env_hash = {'CUSTOM_CONFIG_DIR' => config_dir}
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

          full_spec_task = edict_task :backend_spec, Edicts::Spec do |full_spec|
            full_spec.dir = "backend"
          end
          full_spec_task.set_arg_names(%i(spec_targets))
          task :full => [:check_dependencies, 'frontend:code_structure', :grunt_ci_test, 'backend:setup', :prepare_db, :backend_spec]

          desc "Run all feature specs, repeating with each browser width as default"
          responsivity_edict = Edicts::CleanRun.new do |eddie|
            copy_settings_to(eddie)
            eddie.dir = "backend"
          end
          task :responsivity, [:spec_files] => ['backend:setup', :prepare_db] do |_task, args|
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
          task :fast, [:spec_files] => ['backend:setup', :prepare_db] do |_task, args|
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
