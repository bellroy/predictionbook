source 'http://rubygems.org'

gem 'devise'
gem 'haml-rails'
gem 'jquery-rails'
gem 'rails'
gem 'rails-observers'
# Models
gem 'active_model_serializers'
gem 'chronic'
gem 'kaminari'
gem 'uuidtools'

# Views
gem 'coffee-rails'
gem 'formatize', git: 'https://github.com/jaredjackson/formatize'
gem 'htmlentities'
gem 'RedCloth'
gem 'sass-rails'

# Servers
gem 'mysql2'
gem 'thin'

# App housekeeping
gem 'exception_notification'
gem 'newrelic_rpm'
gem 'whenever'

# allowing CORS
gem 'rack-cors'

# Misc
gem 'hashdiff'
gem 'honeypot-captcha'
gem 'sentry-raven'

group :development do
  gem 'capistrano', '~> 3.5.0'
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-git-submodule-strategy'
  gem 'cap-deploy-tagger'
  gem 'capistrano-rails'
  gem 'httparty'
end

group :test, :development do
  gem 'awesome_print'
  gem 'hirb'
  gem 'poltergeist'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-rails'
  gem 'selenium-webdriver', require: false
  gem 'simplecov'
  gem 'wirble'
end

group :development, :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'timecop'
end

group :test do
  gem 'email_spec'
  gem 'factory_girl'
  gem 'ffaker'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'shoulda-matchers'
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
