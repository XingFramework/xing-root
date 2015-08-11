require 'xing/edicts/clean-rake'

describe Xing::Edicts::CleanRake do

  let :mock_shell do
    instance_double(Caliph::Shell)
  end

  let :test_line do
    "test:command"
  end

  let :command do
    instance_double(Caliph::CommandLine)
  end

  let :result do
    instance_double(Caliph::CommandRunResult)
  end

  let :test_dir do
    "test-dir"
  end

  subject :clean_rake do
    Xing::Edicts::CleanRake.new do |test|
      test.dir = test_dir
      test.task_name = test_line
      test.caliph_shell = mock_shell
    end
  end

  it "should run the command and check output" do
    expect(Bundler).to receive(:with_clean_env).and_yield
    expect(Dir).to receive(:chdir).with(test_dir).and_yield
    allow(clean_rake).to receive(:cmd).with("bundle", "exec", "rake", test_line).and_return(command)
    allow(mock_shell).to receive(:run).with(command).and_return(result)
    expect(result).to receive(:must_succeed!)

    clean_rake.enact
  end
end
