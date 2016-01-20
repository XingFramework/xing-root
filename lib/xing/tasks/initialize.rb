require 'xing/edicts'
require 'xing/tasks/tasklib'

module Xing
  module Tasks
    class Initialize < Tasklib
      default_namespace :initialize

      def define
        in_namespace do
          task :all => ["backend:initialize"]
        end
      end

    end
  end
end
