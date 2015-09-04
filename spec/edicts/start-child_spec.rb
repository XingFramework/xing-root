require 'xing/edicts/start-child'
require 'xing/managers/tmux'

describe Xing::Edicts::StartChild do
  let :manager do
    instance_double Xing::Managers::TmuxPane
  end

  let :task_label do
    "My Cool Task"
  end

  let :task_name do
    "my:cool:task"
  end

  subject :start_child do
    Xing::Edicts::StartChild.new do |sc|
      sc.manager = manager
      sc.label = task_label
      sc.child_task = task_name
    end
  end

  it "should have the manager start a child" do
    expect(manager).to receive(:start_child).with(task_label, task_name)

    start_child.enact
  end
end
