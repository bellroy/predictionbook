# frozen_string_literal: true

require 'selenium/webdriver'

Capybara.register_driver :chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('disable-dev-shm-usage')
  options.add_argument('no-sandbox')
  options.add_argument('headless') unless ENV['SHOW_CHROME']
  options.add_argument('disable-gpu')
  options.add_argument('window-size=1200,960')
  if RUBY_PLATFORM.include?('linux')
    options.binary = `which chromium`.chomp || `which google-chrome-stable`.chomp
  end

  capabilities = Selenium:q:WebDriver::Remote::Capabilities.chrome

  Capybara::Selenium::Driver.new(
    app, browser: :chrome, capabilities: [options, capabilities]
  )
end

Capybara.javascript_driver = :chrome_headless
