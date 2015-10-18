require 'caliph'
require 'edict'

module Xing
  module Edicts
    class CleanRun < Edict::Rule
      include Caliph::CommandLineDSL

      setting :dir
      setting :shell_cmd
      setting :env_hash
      setting :caliph_shell

      def setup_defaults
        super
        @caliph_shell = Caliph::Shell.new
      end

      def setup
        self.env_hash ||= {}
      end

      def action
        Bundler.with_clean_env do
          Dir.chdir(dir) do
            command = cmd(*shell_cmd)

            env_hash.each_pair do |name, value|
              command.set_env(name, value)
            end

            result = caliph_shell.run(command)

            result.must_succeed!
          end
        end
      end
    end
  end
end
