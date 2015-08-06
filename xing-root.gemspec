Gem::Specification.new do |spec|
  spec.name		= "xing-root"
  #{MAJOR: incompatible}.{MINOR added feature}.{PATCH bugfix}-{LABEL}
  spec.version		= "0.0.1"
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
  ]

  spec.test_file        = "spec_help/gem_test_suite.rb"
  spec.licenses = ["MIT"]
  spec.require_paths = %w[lib/]
  spec.rubygems_version = "1.3.5"

  spec.has_rdoc		= true
  spec.extra_rdoc_files = Dir.glob("doc/**/*")
  spec.rdoc_options	= %w{--inline-source }
  spec.rdoc_options	+= %w{--main doc/README }
  spec.rdoc_options	+= ["--title", "#{spec.name}-#{spec.version} Documentation"]

  spec.add_dependency("edict", "> 0")

  #spec.post_install_message = "Thanks for installing my gem!"
end
