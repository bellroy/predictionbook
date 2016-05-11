source 'http://rubygems.org'

gem 'rails'
gem 'rails-observers'
gem 'jquery-rails'
# Models
gem 'chronic'
gem 'version_fu'
gem 'uuidtools'

# Views
gem 'RedCloth'
gem 'formatize', git: 'https://github.com/januszm/formatize'
gem 'htmlentities'

# Servers
gem 'mysql2'
gem 'thin'

# App housekeeping
gem 'exception_notification'
gem 'whenever'
gem 'typus'

gem 'test-unit'

# Misc
gem 'honeypot-captcha'
gem 'httparty'

group :development do
  gem 'capistrano', '~> 2.0'
  gem 'capistrano-ext'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'pry'
  gem 'hirb'
  gem 'wirble'
  gem 'awesome_print'
  gem 'simplecov'
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
  gem 'guard-rspec'
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
  gem 'rb-fsevent', require: false # OSX specific
end
