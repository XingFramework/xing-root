require 'xing/tasks/tasklib'

module Xing
  module Tasks
    class Frontend < Tasklib
      default_namespace :frontend
      setting :dir, "frontend"

      def define
        in_namespace do
          edict_task :npm_install, Edict::CleanRun do |ni|
            ni.shell_cmd = %w{npm install}
          end

          edict_task :bundle_install, Edict::CleanRun do |bi|
            bi.shell_cmd = %w{bundle check || bundle install}
          end

          task :check_dependencies => :npm_install

          task :setup => [:npm_install, :bundle_install]

          namespace :code_structure do
            edict_task :app, Edicts::StructureChecker do |app|
              app.dir = 'frontend/src/app'
            end
            edict_task :common, Edicts::StructureChecker do |common|
              common.dir = 'frontend/src/common'
            end
            edict_task :framework, Edicts::StructureChecker do |fw|
              fw.dir = 'frontend/src/framework'
              fw.context_hash = { :escapes => %w{framework} }
            end
          end

          desc "Apply code structure rules to frontend"
          task :code_structure => %w[code_structure:app code_structure:common code_structure:framework]
        end
      end
    end
  end
end
