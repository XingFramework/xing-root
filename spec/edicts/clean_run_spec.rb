require 'xing/edicts/clean-run'
require 'bundler'

describe Xing::Edicts::CleanRun do

  let :mock_shell do
    instance_double(Caliph::Shell)
  end

  let :test_line do
    %w[a test command]
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

  subject :clean_run do
    Xing::Edicts::CleanRun.new do |test|
      test.dir = test_dir
      test.shell_cmd = test_line
      test.caliph_shell = mock_shell
    end
  end

  it "should run the command and check output" do
    expect(Bundler).to receive(:with_clean_env).and_yield
    expect(Dir).to receive(:chdir).with(test_dir).and_yield
    allow(clean_run).to receive(:cmd).with(*test_line).and_return(command)
    allow(mock_shell).to receive(:run).with(command).and_return(result)
    expect(result).to receive(:must_succeed!)

    clean_run.enact
  end
end
