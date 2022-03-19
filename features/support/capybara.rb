require 'capybara/poltergeist'

# Produce a screenshot for each failure.
require 'capybara-screenshot/cucumber'

Capybara.configure do |config|
  # Capybara 1.x behavior.
  config.match = :prefer_exact

  config.ignore_hidden_elements = false

  # Increased timeout to minimise failures on CI servers.
  config.default_max_wait_time = 25
end

# Reconfigure poltergeist to block twitter:
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app, url_blacklist: ["http://platform.twitter.com", "https://platform.twitter.com"]
  )
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :poltergeist
