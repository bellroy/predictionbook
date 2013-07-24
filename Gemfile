source 'http://rubygems.org'

gem 'rails', '~> 3.1.11'
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
  gem 'rspec-rails', '~> 2.6'
  gem "ruby-debug19"
  gem 'hirb'
  gem 'wirble'
  gem 'awesome_print'
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

