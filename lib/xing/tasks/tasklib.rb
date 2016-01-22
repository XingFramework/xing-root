require 'mattock'

module Xing
  module Tasks
    class Tasklib < Mattock::Tasklib
      def edict_task(*args)
        klass = args.pop
        raise "expected a subclass of Edict::Rule, got #{klass}" unless klass < Edict::Rule
        edict = klass.new do |eddie|
          copy_settings_to(eddie)
          yield eddie if block_given?
        end

        edict_task = task *args do |task, args|
          set_args = Hash[
            (args.keys||[]).find_all do |name|
              !args[name].nil?
            end.map do |name|
              [name, args[name]]
            end
          ]
          edict.from_hash(set_args)
          edict.enact
        end

        # For testing purposes
        edict_task.instance_variable_set("@edict", edict)
        def edict_task.edict
          @edict
        end

        edict_task
      end
    end
  end
end
