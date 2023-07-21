# frozen_string_literal: true

require 'capybara/rspec'
require 'selenium-webdriver'

# there's a bug in capybara-screenshot that requires us to name
#   the driver ":selenium" so we changed it from :headless_chrome"
Capybara.register_driver :selenium do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[headless disable-gpu no-sandbox window-size=1536,1152]
  )
  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    clear_session_storage: true,
    clear_local_storage: true,
    options:
end

Capybara.javascript_driver = :selenium
Capybara.default_max_wait_time = 15
