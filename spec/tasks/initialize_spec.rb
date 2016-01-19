require 'xing/tasks/initialize'


describe Xing::Tasks::Initialize do
  before :each do
    Rake.application = nil
    Xing::Tasks::Initialize.new
  end

  it "creates rake tasks" do
    expect(Rake.application.lookup "initialize:all").to be_a(Rake::Task)
  end

  after :each do
    Rake.application = nil
  end
end
