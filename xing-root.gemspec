Gem::Specification.new do |spec|
  spec.name		= "xing-root"
  #{MAJOR: incompatible}.{MINOR added feature}.{PATCH bugfix}-{LABEL}
  spec.version		= "0.0.3"
  author_list = {
    "Judson Lester" => "judson@lrdesign.com",
    "Patricia Ho" => "patricia@lrdesign.com"
  }
  spec.authors		= author_list.keys
  spec.email		= spec.authors.map {|name| author_list[name]}
  spec.summary		= "The Root of all Xing"
  spec.description	= <<-EndDescription
    The root of all that is Xing in the world.
  EndDescription

  spec.rubyforge_project= spec.name.downcase
  spec.homepage        = ""
  spec.required_rubygems_version = Gem::Requirement.new(">= 0") if spec.respond_to? :required_rubygems_version=

  # Do this: y$@"
  # !!find lib bin doc spec spec_help -not -regex '.*\.sw.' -type f 2>/dev/null
  spec.files		= %w[
    lib/xing/edicts.rb
    lib/xing/tasks.rb
    lib/xing/tasks/backend.rb
    lib/xing/tasks/build.rb
    lib/xing/tasks/frontend.rb
    lib/xing/tasks/tasklib.rb
    lib/xing/tasks/spec.rb
    lib/xing/tasks/develop.rb
    lib/xing/managers/child.rb
    lib/xing/managers/tmux.rb
    lib/xing/edicts/start-child.rb
    lib/xing/edicts/clean-rake.rb
    lib/xing/edicts/clean-run.rb
    lib/xing/edicts/structure-checker.rb
    lib/xing/edicts/launch-browser.rb
    lib/xing-root.rb
    spec/tasks/frontend_spec.rb
    spec/tasks/develop_spec.rb
    spec/tasks/structure_checker_spec.rb
    spec/managers/tmux_spec.rb
    spec/support/file-sandbox.rb
    spec/edicts/start-child_spec.rb
    spec/edicts/clean_run_spec.rb
    spec/edicts/clean_rake_spec.rb
    spec/edicts/launch-browser_spec.rb
  ]

  # spec.test_file        = "spec_help/gem_test_suite.rb"
  spec.licenses = ["MIT"]
  spec.require_paths = %w[lib/]
  spec.rubygems_version = "1.3.5"

  spec.has_rdoc		= true
  spec.extra_rdoc_files = Dir.glob("doc/**/*")
  spec.rdoc_options	= %w{--inline-source }
  spec.rdoc_options	+= %w{--main doc/README }
  spec.rdoc_options	+= ["--title", "#{spec.name}-#{spec.version} Documentation"]

  spec.add_dependency("edict", "< 1.0")
  spec.add_dependency("caliph", "~> 0.3")
  spec.add_dependency("mattock", "~> 0.10")

  #spec.post_install_message = "Thanks for installing my gem!"
end
