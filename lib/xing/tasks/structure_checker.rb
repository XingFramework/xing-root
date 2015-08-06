require 'xing-root'
require 'find'
require 'edict'

module Xing::Tasks
  class StructureCheck < Edict::Rule
    include Find

    setting :dir
    nil_field :context_from_hash

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
          puts "In #{file}"
          problems.each{|prob| puts "  " + prob.to_s}
          puts
        end
        fail
      end
    end

    class Context
      def initialize(hash)
        @escape_clause_list = hash.delete(:escapes) || %w{common framework build}
        raise "Unknown fields in context: #{hash.inspect}" unless hash.empty?
      end

      attr_reader :escape_clause_list
    end

    class Problem < Struct.new(:msg, :line, :lineno, :file)
      def to_s
        "#{lineno}:<#{line}>: #{msg}"
      end
    end

    def problem(msg, line, lineno, file)
      @problems << Problem.new(msg, line.chomp, lineno + 1, file)
    end

    def check_imports(path, context)
      File.read(path).lines.grep(/\s*import/).each_with_index do |import_line, lineno|
        md = /.*from (?<quote>['"])(?<from>.*)\k<quote>/.match(import_line)
        if md.nil?
          problem "doesn't seem to have a 'from' clause...", import_line, lineno, path
        end

        if /\.\./ =~ md[:from]
          if /\A\.\./ !~ md[:from]
            problem "from includes .. not at pos 0", import_line, lineno, path
          end
          if /\w.*\.\./ =~ md[:from]
            problem "from includes .. after words", import_line, lineno, path
          end
          if !(violation = %r{(?<dir>\w+)/\w}.match md[:from]).nil?
            unless %r{\.\./(#{context.escape_clause_list.join("|")})} =~ md[:from]
              problem "Imports Rule: 'from' includes ../ and then #{violation[:dir].inspect} not in #{context.escape_clause_list.inspect}", import_line, lineno, path
            end
          end
        end
      end
    end
  end
end
