source 'http://rubygems.org'

ruby File.read('.ruby-version')

gem 'devise'
gem 'execjs', '~> 2.7.0'
gem 'haml-rails'
gem 'jquery-rails'
gem 'rails', '< 7.0'
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

# allowing CORS
gem 'rack-cors'

# Misc
gem 'hashdiff'
gem 'honeypot-captcha', git: 'https://github.com/RandieM/honeypot-captcha'
gem 'sentry-rails', '>= 4.0'
gem 'sentry-ruby', '>= 4.0'
# Gem ed25519 is required by net-ssh to allow deploys when using this host key: https://github.com/net-ssh/net-ssh#host-keys
gem 'ed25519'
gem 'bcrypt_pbkdf'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'puma'
end

group :deploy do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails'
  gem 'capistrano-rvm', require: false
  gem 'whenever'
  gem 'httparty'
end

group :development, :test do
  gem 'awesome_print'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'hirb'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-rails'
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
  gem 'mini_racer'
end

group :assets do
  gem 'uglifier'
end

group :darwin do
  gem 'rb-fsevent', require: false # OSX specific
end

# Ruby 3.1 needed - We might be able to remove them after Rails 7 upgrade.

gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false

# Need to be locked until we move to Rails => 7.0.3.1 -> There is a way we can update it, but we need to make changes
# to existing code. https://bugs.ruby-lang.org/issues/17866 , https://github.com/rails/rails/commit/179d0a1f474ada02e0030ac3bd062fc653765dbe
gem 'psych',  '< 4'
gem 'zeitwerk', '< 2.6.4' # remove after merging: https://github.com/Shopify/packwerk/pull/251
