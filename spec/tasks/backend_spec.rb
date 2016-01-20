require 'xing/tasks/backend'


describe Xing::Tasks::Backend do
  before :each do
    Rake.application = nil
    Xing::Tasks::Backend.new do |be|
      be.dir = "test-dir"
    end
  end

  it "creates all the backend rake tasks" do
    expect(Rake.application.lookup "backend:bundle_install").to be_a(Rake::Task)
    expect(Rake.application.lookup "backend:check_dependencies").to be_a(Rake::Task)
    expect(Rake.application.lookup "backend:db_create").to be_a(Rake::Task)
    expect(Rake.application.lookup "backend:db_migrate").to be_a(Rake::Task)
    expect(Rake.application.lookup "backend:setup").to be_a(Rake::Task)
    expect(Rake.application.lookup "backend:db_seed").to be_a(Rake::Task)
    expect(Rake.application.lookup "backend:assets_precompile").to be_a(Rake::Task)
    expect(Rake.application.lookup "backend:initialize").to be_a(Rake::Task)
    expect(Rake.application.lookup "backend:all").to be_a(Rake::Task)
  end

  after :each do
    Rake.application = nil
  end
end
