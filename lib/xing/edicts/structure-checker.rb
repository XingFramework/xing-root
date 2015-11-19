require 'xing-root'
require 'find'
require 'edict'

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
        raise Error, "Problems found in ECMAScript structure"
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

    class ImportChecker
      def initialize(path, context)
        @path = path
        @context = context
      end

      attr_reader :path, :context

      def read_next
        @import_line = @lines[@lineno]
      end

      def is_import_line
        /\s*import/.match(@import_line)
      end

      def skip_to_end_of_import
        # for a multi-line import, we need to skip past multiple lines of import
        begin_check = /.*(?<begin>\{).*(?<end>\}?)/.match(@import_line)
        if begin_check and begin_check[:begin] and begin_check[:end].empty?
          begin
            @lineno += 1
            read_next
            end_check = /.*(?<end>\}).*/.match(@import_line)
          end while !end_check
        end
      end

      def match_line
        @md = /.*from (?<quote>['"])(?<from>.*)\k<quote>/.match(@import_line)
      end

      def check_empty_match
        if @md.nil?
          problem "doesn't seem to have a 'from' clause...", @import_line, @lineno, path
        end
      end

      def check_structure
        if /\.\./ =~ @md[:from]
          if /\A\.\./ !~ @md[:from]
            problem "from includes .. not at pos 0"
          end
          if /\w.*\.\./ =~ @md[:from]
            problem "from includes .. after words"
          end
          if !(violation = %r{(?<dir>\w+)/\w}.match @md[:from]).nil?
            unless %r{\.\./(#{context.escape_clause_list.join("|")})} =~ @md[:from]
              problem "Imports Rule: 'from' includes ../ and then #{violation[:dir].inspect} not in #{context.escape_clause_list.inspect}"
            end
          end
        end
      end

      def problem(message)
        @error_block.call(message, @import_line, @lineno)
      end

      def check(&error_block)
        @error_block = error_block
        @lines = File.read(path).lines
        @lineno = 0
        while @lineno < @lines.length
          read_next
          if is_import_line
            skip_to_end_of_import
            match_line
            check_empty_match
            check_structure
          end
          @lineno += 1
        end
      end
    end

    def check_imports(path, context)
      checker = ImportChecker.new(path, context)
      checker.check do |message, line, lineno|
        problem message, line, lineno, path
      end
    end
  end
end
