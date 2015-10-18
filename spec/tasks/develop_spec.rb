require 'xing/tasks/develop'


describe Xing::Tasks::Develop do
  before :each do
    Rake.application = nil
    Xing::Tasks::Develop.new
  end

  it "creates all the develop rake tasks" do
    expect(Rake.application.lookup "develop:launch_browser").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:grunt_watch").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:compass_watch").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:rails_server").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:sidekiq").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:static_assets").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:service:grunt_watch").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:service:compass_watch").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:service:rails_server").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:service:sidekiq").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:service:static_assets").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:wait").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:startup").to be_a(Rake::Task)
    expect(Rake.application.lookup "develop:all").to be_a(Rake::Task)
  end

  it "doesn't create TMUX clones" do
    manager = Rake.application.lookup("develop:grunt_watch").edict.manager
    expect(Rake.application.lookup("develop:compass_watch").edict.manager).to eql(manager)
    expect(Rake.application.lookup("develop:rails_server").edict.manager).to eql(manager)
    expect(Rake.application.lookup("develop:sidekiq").edict.manager).to eql(manager)
    expect(Rake.application.lookup("develop:static_assets").edict.manager).to eql(manager)
  end

  it "creates correct child tasks" do
    expect(Rake.application.lookup("develop:grunt_watch").edict.child_task).to eq('develop:service:grunt_watch')
    expect(Rake.application.lookup("develop:compass_watch").edict.child_task).to eq('develop:service:compass_watch')
    expect(Rake.application.lookup("develop:rails_server").edict.child_task).to eq('develop:service:rails_server')
    expect(Rake.application.lookup("develop:sidekiq").edict.child_task).to eq('develop:service:sidekiq')
    expect(Rake.application.lookup("develop:static_assets").edict.child_task).to eq('develop:service:static_assets')
  end

  after :each do
    Rake.application = nil
  end
end
