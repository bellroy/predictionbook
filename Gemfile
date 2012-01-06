source 'http://rubygems.org'

gem 'rails', '~> 3.1.3'
gem "mysql2", '~> 0.3'
gem 'chronic', '0.3.0'
gem "version_fu", "~> 1.0.1"

gem 'exception_notification'

gem 'jquery-rails'
gem 'RedCloth', '~>4.2.7'
gem 'uuidtools', '~> 1.0.0'
gem 'formatize'

group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'uglifier', '>= 1.0.3'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.6'
  gem "ruby-debug"
  gem 'hirb'
  gem 'wirble'
  gem 'awesome_print'
  gem 'rb-fsevent', :require => false #OSX specific
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
