module Xing::Edicts
  class StartChild < Edict::Rule
    setting :manager
    setting :label
    setting :child_task

    def action
      puts "TMUX MANAGER is #{manager.object_id}"
      manager.start_child(label, child_task)
    end
  end
end
