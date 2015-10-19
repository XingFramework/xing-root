require 'cadre/simplecov'
require 'simplecov-json'
SimpleCov.start do
  coverage_dir "corundum/docs/coverage"
  add_filter ".*_spec.rb"
  add_filter "vendor/bundle"
  add_filter "spec/support/"
  add_filter "spec_help/"

  formatter SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Cadre::SimpleCov::VimFormatter,
    SimpleCov::Formatter::JSONFormatter
  ]
end
