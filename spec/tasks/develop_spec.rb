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

  after :each do
    Rake.application = nil
  end
end
