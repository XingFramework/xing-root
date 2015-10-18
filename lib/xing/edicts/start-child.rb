module Xing::Edicts
  class StartChild < Edict::Rule
    setting :manager
    setting :label
    setting :child_task

    def action
      manager.start_child(label, child_task)
    end
  end
end
