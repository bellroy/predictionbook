source 'http://rubygems.org'

gem 'rails', '~> 3.1.3'
gem "mysql2", '~> 0.3'
gem 'chronic', '0.3.0'
gem "version_fu", "~> 1.0.1"

gem 'exception_notification'

gem 'restful-authentication', :git => "git://github.com/Satish/restful-authentication", :ref => '63aeed7a2eeb00be8491',
                              :branch => 'rails3'

gem 'jquery-rails'
gem 'RedCloth', '~>4.2.7'
gem 'uuidtools', '~> 1.0.0'


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
  # gem 'rspec-caching-test-plugin', :git=> 'git://github.com/econsultancy/rspec-caching-test-plugin.git',
                                   # :branch=> 'econsultancy-2011-08-05',
                                   # :require=> 'cache_test'
end
