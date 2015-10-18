require 'mattock'

module Xing
  module Tasks
    class Tasklib < Mattock::Tasklib
      def edict_task(name, klass, &block)
        edict = klass.new do |eddie|
          copy_settings_to(eddie)
          yield eddie if block_given?
        end
        edict_task = task name do
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
