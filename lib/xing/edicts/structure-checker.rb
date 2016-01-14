require 'xing-root'
require 'find'
require 'edict'
require 'xing/utils/import_checker'

module Xing::Edicts
  class StructureChecker < Edict::Rule
    include Find

    class Error < ::StandardError
    end

    setting :dir
    nil_field :context_hash
    setting :out_stream, $stdout

    def setup
      @problems = []
    end

    def action
      analyze
      report
    end

    def analyze
      context = context_from_hash(context_hash || {:escapes => %w{common framework build}})
      return unless File.directory?(dir)
      find(dir) do |path|
        if File.directory?(path)
        else
          next if File.basename(path)[0] == ?.
          case path
          when /\.js\z/
            check_imports(path, context)
          end
        end
      end
    end

    def context_from_hash(hash)
      Context.new(hash)
    end

    def report
      unless @problems.empty?
        @problems.group_by do |problem|
          problem.file
        end.each do |file, problems|
          out_stream.puts "In #{file}"
          problems.each{|prob| out_stream.puts "  " + prob.to_s}
          out_stream.puts
        end
        out_stream.puts "Problems found in ECMAScript structure"
        #raise Error, "Problems found in ECMAScript structure"
      end
    end

    class Context
      def initialize(hash)
        @escape_clause_list = hash.delete(:escapes) || %w{common framework build}
        raise "Unknown fields in context: #{hash.inspect}" unless hash.empty?
      end

      attr_reader :escape_clause_list
    end

    class Problem < ::Struct.new(:msg, :line, :lineno, :file)
      def to_s
        "#{lineno}:<#{line}>: #{msg}"
      end
    end

    def problem(msg, line, lineno, file)
      @problems << Problem.new(msg, line.chomp, lineno + 1, file)
    end

    def check_imports(path, context)
      checker = Xing::Utils::ImportChecker.new(path, context)
      checker.check do |message, line, lineno|
        problem message, line, lineno, path
      end
    end
  end
end
