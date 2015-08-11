require 'edict'
require 'xing/edicts/clean-run'

module Xing
  module Edicts
    class CleanRake < CleanRun

      setting :task_name

      def setup
        super
        self.shell_cmd = %w[bundle exec rake] + [task_name]
      end
    end
  end
end
