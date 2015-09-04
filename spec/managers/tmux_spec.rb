require 'xing/managers/tmux'

describe Xing::Managers::TmuxPane do
  let :lines_value do
    "40\n"
  end

  let :cols_value do
    "160\n"
  end

  before :each do
    allow(lines_result).to receive(:stdout).and_return(lines_value)
    allow(cols_result).to receive(:stdout).and_return(cols_value)
    allow(mock_shell).to receive(:run).with("tput lines").and_return(lines_result)
    allow(mock_shell).to receive(:run).with("tput cols").and_return(cols_result)
    allow(tmux_pane).to receive(:puts)
  end

  def self.command(name)
    let name do
      instance_double(Caliph::CommandLine, name).tap do |cl|
        allow(cl).to receive(:string_format).and_return("format of #{name}")
      end
    end
  end

  command(:list_cmd)
  command(:new_session_command)

  let (:lines_result) { instance_double(Caliph::CommandRunResult) }
  let (:cols_result) { instance_double(Caliph::CommandRunResult) }
  let (:mock_shell) { instance_double(Caliph::Shell) }
  let (:list_result) { instance_double(Caliph::CommandRunResult) }
  let (:new_session_result) { instance_double(Caliph::CommandRunResult) }
  let (:which_tmux_result) { instance_double(Caliph::CommandRunResult) }

  let :task_name do
    "ha:ha:ha"
  end

  let :tmux_path do
    "usr/bin/tmux"
  end


  subject :tmux_pane do
    Xing::Managers::TmuxPane.new(mock_shell)
  end

  before :each do
    allow(list_result).to receive(:stdout).and_return("nothing important")
    allow(new_session_result).to receive(:stdout).and_return("nothing important")
    allow(new_session_command).to receive(:string_format).and_return("")
    allow(which_tmux_result).to receive(:stdout).and_return(tmux_path)
    allow(which_tmux_result).to receive(:succeeds?)
    allow(mock_shell).to receive(:run).with("which", "tmux").and_return(which_tmux_result)
    allow(tmux_pane).to receive(:cmd).with(tmux_path, match(%r{\Alist-windows})).and_return(list_cmd)
    allow(mock_shell).to receive(:run).with(list_cmd).and_return(list_result)
  end

  it "first child gets a new window" do
    allow(tmux_pane).to receive(:cmd).with(tmux_path, match(%r{\Anew-window})).and_return(new_session_command)

    expect(mock_shell).to receive(:run).with(new_session_command).and_return(new_session_result)
    tmux_pane.start_child("something", task_name)
  end

  describe "second child" do
    before :each do
      # create first child
      allow(tmux_pane).to receive(:cmd).with(tmux_path, match(%r{\Anew-window})).and_return(new_session_command)
      allow(mock_shell).to receive(:run).with(new_session_command).and_return(new_session_result)
      tmux_pane.start_child("something", task_name)
    end

    command(:new_window_command)
    command(:join_pane_command)

    it "gets a new pane" do
      expect(tmux_pane).to receive(:cmd).with(tmux_path, match(%r{\Anew-window})).and_return(new_window_command)
      expect(tmux_pane).to receive(:cmd).with(tmux_path, match(%r{\Ajoin-pane})).and_return(join_pane_command)
      expect(mock_shell).to receive(:run).with(new_window_command).and_return(new_session_result)
      expect(mock_shell).to receive(:run).with(join_pane_command).and_return(new_session_result)
      tmux_pane.start_child("something", task_name)
    end

    describe "in small terminal" do

      let :lines_value do
        "15\n"
      end

      let :cols_value do
        "40\n"
      end

      it "gets a new window" do
        expect(tmux_pane).to receive(:cmd).with(tmux_path, match(%r{\Anew-window})).and_return(new_window_command)
        expect(tmux_pane).to receive(:cmd).with(tmux_path, match(%r{\Aselect-layout})).and_return(new_window_command)
        expect(mock_shell).to receive(:run).with(new_window_command).at_least(:twice).and_return(new_session_result)
        tmux_pane.start_child("something", task_name)
      end
    end
  end
end
