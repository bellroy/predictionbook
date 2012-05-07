source 'http://rubygems.org'

gem 'rails', '~> 3.1.3'
gem 'jquery-rails'

#Models
gem 'chronic'
gem "version_fu", "~> 1.0.1"
gem 'uuidtools', '~> 1.0.0'

#Views
gem 'RedCloth', '~>4.2.7'
gem 'formatize'

#Servers
gem "mysql2", '~> 0.3'
gem 'thin'

#App housekeeping
gem 'exception_notification'
gem "typus"

group :development do
  gem "capistrano"
  gem "capistrano-ext"
end

group :test, :development do
  gem 'rspec-rails', '~> 2.6'
  gem "ruby-debug19"
  gem 'hirb'
  gem 'wirble'
  gem 'awesome_print'
  gem 'rb-fsevent', :require => false #OSX specific
end

group :cucumber, :development do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'gherkin', '~> 2.7.1'
  gem 'cucumber-rails', '~> 1.2.0'
  gem 'cucumber', '~> 1.1.4'
end

group :test do
  gem 'factory_girl'
  gem 'database_cleaner'
  gem 'ffaker'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem "guard-rspec"
  gem 'email_spec'
end

#restful-authentication needs to be installed as a plugin or it doesn't work
#rspec-caching-test-plugin is quite old and is not available as a gem
