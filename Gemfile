source ENV['GEM_SOURCE'] || "https://rubygems.org"
ruby "2.3.0"

group :unit_tests do
  gem 'rake', '< 11.0', require: false
  gem 'rspec', '~> 3.1.0', require: false
  gem 'rspec-puppet', require: false
  gem 'puppetlabs_spec_helper', require: false
  gem 'puppet-lint', require: false
  gem 'metadata-json-lint', require: false
end

group :development do
  gem 'guard-rake', require: false
end

gem 'puppet', require: false
