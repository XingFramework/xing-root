require 'xing/tasks/spec'

describe Xing::Tasks::Spec do
  before :each do
    Rake.application = nil
    Xing::Tasks::Spec.new
  end

  it "creates all the backend rake tasks" do
    expect(Rake.application.lookup "spec:grunt_ci_test").to be_a(Rake::Task)
    expect(Rake.application.lookup "spec:links:index.html").to be_a(Rake::Task)
    expect(Rake.application.lookup "spec:links:assets").to be_a(Rake::Task)
    expect(Rake.application.lookup "spec:links:fonts").to be_a(Rake::Task)
    expect(Rake.application.lookup "spec:full").to be_a(Rake::Task)
    expect(Rake.application.lookup "spec:prepare_db").to be_a(Rake::Task)
    expect(Rake.application.lookup "spec:responsivity").to be_a(Rake::Task)
    expect(Rake.application.lookup "spec:fast").to be_a(Rake::Task)
  end

  after :each do
    Rake.application = nil
  end
end
