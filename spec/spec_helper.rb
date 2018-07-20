require 'simplecov'
SimpleCov.start do
  add_filter '/vendor/'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/examples/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false
  config.use_instantiated_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  config.include Rails.application.routes.url_helpers, type: :views
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Warden::Test::Helpers
  config.before :suite do
    Warden.test_mode!
    log_path = Rails.root.join('log', 'test.log')
    system("cat /dev/null > #{log_path}")
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:example) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:example, type: :feature) do
    DatabaseCleaner.strategy = :deletion
  end

  config.before(:example) do
    DatabaseCleaner.start
    Capybara.reset_sessions!
  end

  config.after(:example) do
    DatabaseCleaner.clean
  end
end
