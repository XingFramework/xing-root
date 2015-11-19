require 'xing/utils/import_checker'
require 'support/file-sandbox'
require 'stringio'

describe Xing::Utils::ImportChecker do
  include FileSandbox

  let :stdout do
    StringIO.new
  end

  let :errors do
    []
  end

  let :context do
    double("context", :escape_clause_list => ['common', 'framework'])
  end

  subject :checker do
    Xing::Utils::ImportChecker.new("test-dir/problem.js", context)
  end

  describe "with a problem file" do

    before :each do
      @sandbox.new :file => "test-dir/problem.js", :with_content => "import Thing from '../../../somewhere/bad.js';"
      checker.check do |message, import_line, lineno|
        errors << [message, import_line, lineno]
      end
    end

    it "should report errors" do
      expect(errors).to_not be_empty
      expect(errors[0][0]).to match(%r{'from' includes ../})
    end
  end

  describe "with a good file" do
    before :each do
      @sandbox.new :file => "test-dir/problem.js", :with_content => "import Thing from 'somewhere/okay.js';"
      checker.check do |message, import_line, lineno|
        errors << [message, import_line, lineno]
      end
    end

    it "should not report errors" do
      expect(errors).to be_empty
    end
  end

  describe "multi-line import" do
    describe "with a problem file" do
      before :each do
        @sandbox.new :file => "test-dir/problem.js", :with_content => <<-eos
          import {
            Thing,
            OtherThing
          } from '../../../somewhere/bad.js';"
        eos
        checker.check do |message, import_line, lineno|
          errors << [message, import_line, lineno]
        end
      end

      it "should report errors" do
        expect(errors).to_not be_empty
        expect(errors[0][0]).to match(%r{'from' includes ../})
      end
    end

    describe "with a good file" do
      before :each do
        @sandbox.new :file => "test-dir/problem.js", :with_content => <<-eos
          import {
            Thing,
            OtherThing
          } from 'somewhere/okay.js';"
        eos
        checker.check do |message, import_line, lineno|
          errors << [message, import_line, lineno]
        end
      end

      it "should not report errors" do
        expect(errors).to be_empty
      end
    end
  end
end
