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

          edict_task(:backend_spec, {%i(spec_targets) => %w(backend:setup prepare_db)}, Edicts::Spec) do |full_spec|
            full_spec.dir = "backend"
          end
          task :full => [:check_dependencies, 'frontend:code_structure', :grunt_ci_test, 'backend:setup', :prepare_db, :backend_spec]

          namespace :responsivity do
            %w{mobile small medium desktop}.each do |size|
              edict_task(size, {%i(spec_files) => %w(backend:setup prepare_db)}, Edicts::Spec) do |resp|
                resp.shell_cmd = ["bundle", "exec", "rspec", "-o", "tmp/rspec_#{size}.txt"]
                resp.env_hash = {'BROWSER_SIZE' => size}
                resp.dir = 'backend'
              end
            end
          end

          desc "Run all feature specs, repeating with each browser width as default"
          task :responsivity, [:spec_files] => %w{responsivity:mobile responsivity:small responsivity:medium responsivity:desktop}

          edict_task(:fast, {%i(spec_targets) => %w(backend:setup prepare_db)}, Edicts::Spec) do |fast_spec|
            fast_spec.dir = "backend"
            fast_spec.shell_cmd = %w{bundle exec rspec}
            fast_spec.spec_targets = %w(--tag ~type:feature)
          end
        end
      end
    end
  end
end
