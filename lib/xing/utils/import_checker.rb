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
      problem "doesn't seem to have a 'from' clause..." if @md.nil?
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
      initialize_check(error_block)
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
end
