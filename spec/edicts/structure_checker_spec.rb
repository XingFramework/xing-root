require 'xing/edicts/structure-checker'
require 'support/file-sandbox'
require 'stringio'

describe Xing::Edicts::StructureChecker do
  include FileSandbox

  subject :checker do
    Xing::Edicts::StructureChecker.new do |checker|
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
      subject.action
      #expect{subject.action}.to raise_error(Xing::Edicts::StructureChecker::Error)
      expect(stdout.string).to match("Problems found in ECMAScript structure")
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
      expect(stdout.string).to be_empty
    end
  end

end
