require 'mattock'

module Xing
  module Tasks
    class Tasklib < Mattock::Tasklib
      def edict_task(name, klass, &block)
        edict = klass.new do |eddie|
          copy_settings_to(eddie)
          yield eddie if block_given?
        end
        task name do
          edict.enact
        end
      end
    end
  end
end
