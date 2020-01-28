require_relative 'lib/version'

# frozen_string_literal: true
Gem::Specification.new do |gem|
  gem.name               = "composer-summary"
  gem.version            = VERSION

  gem.authors = ["Austin Pray"]
  gem.email = 'austin@carrot.com'
  gem.date = '2020-01-25'
  gem.description = 'Automatically document your composer dependencies'
  gem.summary = gem.description
  gem.homepage = 'https://github.com/oncarrot/composer-summary'

  gem.files = ['bin/composer-summary'] + Dir['{lib,templates}/**/*.{rb,md}']

  gem.executables = ['composer-summary']

  gem.test_files = Dir[File.join(__dir__,)]

  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.5.0"
end
