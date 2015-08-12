require 'xing/tasks/frontend'


describe Xing::Tasks::Frontend do
  before :each do
    Rake.application = nil
    Xing::Tasks::Frontend.new do |fe|
      fe.dir = "test-dir"
    end
  end

  it "creates all the frontend rake tasks" do
    expect(Rake.application.lookup "frontend:npm_install").to be_a(Rake::Task)
    expect(Rake.application.lookup "frontend:bundle_install").to be_a(Rake::Task)
    expect(Rake.application.lookup "frontend:check_dependencies").to be_a(Rake::Task)
    expect(Rake.application.lookup "frontend:setup").to be_a(Rake::Task)
    expect(Rake.application.lookup "frontend:code_structure").to be_a(Rake::Task)
    expect(Rake.application.lookup "frontend:code_structure:app").to be_a(Rake::Task)
    expect(Rake.application.lookup "frontend:code_structure:common").to be_a(Rake::Task)
    expect(Rake.application.lookup "frontend:code_structure:framework").to be_a(Rake::Task)
  end

  after :each do
    Rake.application = nil
  end
end
