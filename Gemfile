source 'http://rubygems.org'

gem 'rails', '~> 3.2.1'
gem 'jquery-rails'
#Models
gem 'chronic'
gem "version_fu", "~> 1.0.1"
gem 'uuidtools', '~> 1.0.0'

#Views
gem 'RedCloth', '~>4.2.7'
gem 'formatize'
gem 'htmlentities'

#Servers
gem "mysql2", '~> 0.3'
gem 'thin'

#App housekeeping
gem 'exception_notification'
gem "whenever"
gem "typus"

#Misc
gem 'honeypot-captcha'

group :development do
  gem "capistrano"
  gem "capistrano-ext"
end

group :test, :development do
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem "pry"
  gem 'hirb'
  gem 'wirble'
  gem 'awesome_print'
end

group :cucumber, :development do
  gem 'launchy'
  gem 'gherkin'
  gem 'cucumber-rails'
  gem 'cucumber'
end

group :cucumber, :development, :test do
  gem 'capybara'
  gem 'database_cleaner'
end

group :test do
  gem 'factory_girl'
  gem 'ffaker'
  gem 'shoulda-matchers'
  gem "guard-rspec"
  gem 'email_spec'
end

group :assets do
  gem 'uglifier'
end

group :linux, :production do
  # Does not build on Mountain Lion nor is it needed on OS X
  gem 'therubyracer'
end

group :darwin do
  gem 'rb-fsevent', :require => false #OSX specific
end


#restful-authentication needs to be installed as a plugin or it doesn't work
#rspec-caching-test-plugin is quite old and is not available as a gem

