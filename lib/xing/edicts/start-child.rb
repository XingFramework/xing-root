module Xing::Edicts
  class StartChild < Edict::Rule
    setting :manager, :label, :child_task

    def action
      manager.start_child(label, child_task)
    end
  end
end
