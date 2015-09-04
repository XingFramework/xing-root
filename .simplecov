require 'cadre/simplecov'
require 'simplecov-json'
SimpleCov.start do
  coverage_dir "corundum/docs/coverage"
  add_filter "./spec"
  add_filter "vendor/bundle"

  formatter SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Cadre::SimpleCov::VimFormatter,
    SimpleCov::Formatter::JSONFormatter
  ]
end
