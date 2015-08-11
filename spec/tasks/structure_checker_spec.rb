require 'xing/tasks/structure_checker'
require 'support/file-sandbox'
require 'stringio'

describe Xing::Tasks::StructureChecker do
  include FileSandbox

  subject :checker do
    Xing::Tasks::StructureChecker.new do |checker|
      checker.dir = "test-dir"
      checker.out_stream = stdout
    end
  end

  let :stdout do
    StringIO.new
  end

  describe "with a problem file" do
    before :each do
      @sandbox.new :file => "test-dir/problem.js", :with_content => "import Thing from '../../../somewhere/bad.js';"
    end

    it "should report errors" do
      expect{subject.action}.to raise_error(Xing::Tasks::StructureChecker::Error)
      expect(stdout.string).to match(%r{In test-dir/problem.js})
      expect(stdout.string).to match(%r{'from' includes ../})
    end
  end

  describe "with a good file" do
    before :each do
      @sandbox.new :file => "test-dir/problem.js", :with_content => "import Thing from 'somewhere/okay.js';"
    end

    it "should not report errors" do
      expect{subject.action}.not_to raise_error
    end
  end

end
