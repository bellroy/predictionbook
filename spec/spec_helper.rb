ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
Dir[Rails.root.join("spec/factories/**/*.rb")].each {|f| require f}

FG = FactoryGirl

VCR.config do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.stub_with :webmock
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.render_views
  config.include Devise::TestHelpers, :type => :controller
  config.include Capybara::DSL, :type => :controller
  config.include ControllerMacros, :type => :controller
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.extend VCR::RSpec::Macros
end

