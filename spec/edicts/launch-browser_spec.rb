require 'json'
require 'xing/edicts/launch-browser'

describe Xing::Edicts::LaunchBrowser do
  let :mock_reload_connection do
    instance_double(TCPSocket)
  end

  let :reload_server_port do
    37590
  end

  let :static_server_port do
    9292
  end

  let :reload_uri do
    URI("http://localhost:#{reload_server_port}/changed")
  end

  let :static_url do
    "http://localhost:#{static_server_port}/"
  end

  let :mock_shell do
    instance_double(Caliph::Shell)
  end

  let :which_cmd do
    instance_double(Caliph::CommandLine)
  end

  let :launch_cmd do
    instance_double(Caliph::CommandLine)
  end

  let :success_result do
    instance_double(Caliph::CommandRunResult)
  end

  subject :launch_browser do
    Xing::Edicts::LaunchBrowser.new do |lb|
      lb.caliph_shell = mock_shell
      lb.reload_server_port = reload_server_port
      lb.static_server_port = static_server_port
      lb.max_wait = 0.1
    end
  end

  before :each do
    allow(TCPSocket).to receive(:new).with('localhost', reload_server_port).and_return(mock_reload_connection)
    expect(mock_reload_connection).to receive(:close)
    allow(Net::HTTP).to receive(:get).with(reload_uri).and_return(changed_json)

    allow(launch_browser).to receive(:cmd).with('which', 'open').and_return(which_cmd)
    allow(mock_shell).to receive(:run).with(which_cmd).and_return(success_result)
    allow(success_result).to receive(:succeeds?).and_return(true)
    allow(success_result).to receive(:must_succeed!).and_return(true)

    allow(launch_browser).to receive(:cmd).with('open', static_url).and_return(launch_cmd)
  end

  describe "when no browser is running" do
    let :changed_json do
      {
        :clients => []
      }.to_json
    end

    it "should launch a new browser" do
      expect(mock_shell).to receive(:run).with(launch_cmd).and_return(success_result)

      launch_browser.check_required
      launch_browser.subprocess_action #because fork
    end
  end

  describe "when an existing browser is connected" do
    let :changed_json do
      {
        :clients => ["someone else"]
      }.to_json
    end

    it "should not launch a new browser" do
      expect(mock_shell).not_to receive(:run).with(launch_cmd)
      launch_browser.check_required
      launch_browser.subprocess_action #because fork
    end
  end
end
