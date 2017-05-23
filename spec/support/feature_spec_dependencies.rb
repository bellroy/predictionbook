# frozen_string_literal: true

if ENV['USE_SELENIUM']
  require 'selenium/webdriver'

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app)
  end

  Capybara.javascript_driver = :selenium
  Capybara.run_server        = true
  Capybara.server_port       = 30_000
  Capybara.default_max_wait_time = 10
else
  require 'capybara/poltergeist'

  phantomjs_options = [
    '--ssl-protocol=any',
    '--ignore-ssl-errors=yes',
    '--load-images=no',
    '--disk-cache=true'
  ]

  phantomjs_options << '--debug=true' if ENV['DEBUG_PHANTOMJS']

  Capybara.register_driver :poltergeist do |app|
    options = {
      timeout: 30,
      phantomjs_options: phantomjs_options
    }
    Capybara::Poltergeist::Driver.new(app, options)
  end

  Capybara.javascript_driver = :poltergeist
end
