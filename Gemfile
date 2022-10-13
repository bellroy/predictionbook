source 'http://rubygems.org'

ruby File.read('.ruby-version')

gem 'devise'
gem 'execjs', '~> 2.7.0'
gem 'haml-rails'
gem 'jquery-rails'
gem 'rails', '~> 5.0'
gem 'rails-observers'

# Models
gem 'active_model_serializers'
gem 'chronic'
gem 'gutentag', '~> 2.6'
gem 'kaminari'
gem 'uuidtools'

# Views
gem 'coffee-rails'
gem 'formatize', git: 'https://github.com/jaredjackson/formatize'
gem 'htmlentities'
gem 'RedCloth'
gem 'sass-rails'

# Servers
gem 'pg'
gem 'thin'

# App housekeeping
gem 'exception_notification'
gem 'whenever'

# allowing CORS
gem 'rack-cors'

# Misc
gem 'hashdiff'
gem 'honeypot-captcha', git: 'https://github.com/RandieM/honeypot-captcha'
gem 'sentry-rails', '>= 4.0'
gem 'sentry-ruby', '>= 4.0'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'capistrano-bundler', require: false
  gem 'capistrano-git-with-submodules'
  gem 'capistrano-rails'
  gem 'capistrano-rvm', require: false
  gem 'httparty'
  gem 'puma'
end

group :development, :test do
  gem 'awesome_print'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'hirb'
  gem 'poltergeist'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-rails'
  gem 'selenium-webdriver', require: false
  gem 'simplecov'
  gem 'timecop'
  gem 'wirble'
end

group :test do
  gem 'email_spec'
  gem 'factory_bot'
  gem 'ffaker'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'webdrivers'
end

group :linux, :production do
  # Does not build on Mountain Lion nor is it needed on OS X
  gem 'therubyracer'
end

group :assets do
  gem 'uglifier'
end

group :darwin do
  gem 'rb-fsevent', require: false # OSX specific
end
