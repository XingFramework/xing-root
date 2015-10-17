require 'xing/tasks/build'


describe Xing::Tasks::Build do
  before :each do
    Rake.application = nil
    Xing::Tasks::Build.new
  end

  it "creates all the build rake tasks" do
    expect(Rake.application.lookup "build:all").to be_a(Rake::Task)
    expect(Rake.application.lookup "build:frontend:grunt_compile").to be_a(Rake::Task)
    expect(Rake.application.lookup "build:frontend:all").to be_a(Rake::Task)
  end

  after :each do
    Rake.application = nil
  end
end
