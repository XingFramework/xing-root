module Xing::Utils
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
      /^\s*import/.match(@import_line)
    end

    def skip_to_end_of_import
      # for a multi-line import, we need to skip past multiple lines of import
      begin_check = /.*(?<begin>\{).*/.match(@import_line)
      end_check = /.*(?<end>\}).*/.match(@import_line)
      if begin_check and !end_check
        until end_check
          @lineno += 1
          read_next
          end_check = /.*(?<end>\}).*/.match(@import_line)
        end
      end
    end

    def match_line
      @md = /.*from (?<quote>['"])(?<from>.*)\k<quote>/.match(@import_line)
    end

    def check_empty_match
      if @md.nil?
        problem "doesn't seem to have a 'from' clause..."
        true
      else
        false
      end
    end

    def check_structure
      if /\.\./ =~ @md[:from]
        problem "from includes .. not at pos 0" if /\A\.\./ !~ @md[:from]
        problem "from includes .. after words" if /\w.*\.\./ =~ @md[:from]
        unless (violation = %r{(?<dir>\w+)/\w}.match @md[:from]).nil?
          unless %r{\.\./(#{context.escape_clause_list.join("|")})} =~ @md[:from]
            problem "Imports Rule: 'from' includes ../ and then #{violation[:dir].inspect} not in #{context.escape_clause_list.inspect}"
          end
        end
      end
    end

    def problem(message)
      @error_block.call(message, @import_line, @lineno)
    end

    def initialize_check(error_block)
      @error_block = error_block
      @lines = File.read(path).lines
      @lineno = 0
    end

    def check(&error_block)
      begin
        initialize_check(error_block)
        while @lineno < @lines.length
          read_next
          if is_import_line
            skip_to_end_of_import
            match_line
            check_structure if !check_empty_match
          end
          @lineno += 1
        end
      rescue
      end
    end
  end
end
