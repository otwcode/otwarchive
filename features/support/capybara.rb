# Produce a screenshot for each failure.
require 'capybara-screenshot/cucumber'

# Use environment variables to set the host and the port used for tests:
CAPYBARA_HOST = ENV["DOCKER"] ? `hostname`.strip : "localhost"
CAPYBARA_PORT = ENV["CAPYBARA_PORT"] || 5100
CAPYBARA_URL = "http://#{CAPYBARA_HOST}:#{CAPYBARA_PORT}".freeze

Capybara.configure do |config|
  # Capybara 1.x behavior.
  config.match = :prefer_exact

  # Increased timeout to minimise failures on CI servers.
  config.default_max_wait_time = 25

  # Capybara 2.x behavior: match rendered text, squish whitespace by default.
  config.default_normalize_ws = true

  # Capybara 3.x changes the default server to Puma; we have WEBRick
  # (a dependency of Mechanize, used for importing; also used for the
  # Rails development server), so we'll stick with that for now.
  config.server = :webrick

  # Make server accessible from the outside world. Note that we don't use
  # CAPYBARA_HOST here because this is the IP that the server binds to, not the
  # host that we want to use for tests:
  config.server_host = "0.0.0.0" if ENV["CHROME_URL"]

  # Specify the port used for tests:
  config.server_port = CAPYBARA_PORT
end

# Modified from https://github.com/teamcapybara/capybara/blob/49cf69c40f4b25931aecab162fb3285d8fe5bff7/lib/capybara/registrations/drivers.rb#L31-L42
Capybara.register_driver :selenium_chrome_headless do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument("--headless")

    # Workaround from https://bugs.chromium.org/p/chromedriver/issues/detail?id=2660#c13
    opts.add_argument("--disable-site-isolation-trials")
  end

  options = if ENV["CHROME_URL"]
              # Special handling for Docker, modified from the instructions at
              # https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing
              { browser: :remote, options: browser_options, url: ENV["CHROME_URL"] }
            else
              { browser: :chrome, options: browser_options }
            end

  Capybara::Selenium::Driver.new(app, **options)
end

# Make sure we get full-page screenshots on failure:
Capybara::Screenshot.register_driver :selenium_chrome_headless do |driver, path|
  # From https://github.com/madebylotus/capybara-full_screenshot/blob/bf1c3ede89e01b847f7b0dc7d71cd73b25175cd5/lib/capybara/full_screenshot/rspec_helpers.rb#L5-L8
  width = Capybara.page.execute_script(<<~WIDTH_SCRIPT.squish)
    return Math.max(document.body.scrollWidth,
                    document.body.offsetWidth,
                    document.documentElement.clientWidth,
                    document.documentElement.scrollWidth,
                    document.documentElement.offsetWidth);
  WIDTH_SCRIPT

  height = Capybara.page.execute_script(<<~HEIGHT_SCRIPT.squish)
    return Math.max(document.body.scrollHeight,
                    document.body.offsetHeight,
                    document.documentElement.clientHeight,
                    document.documentElement.scrollHeight,
                    document.documentElement.offsetHeight);
  HEIGHT_SCRIPT

  Capybara.current_session.current_window.resize_to(width + 100, height + 100)

  driver.browser.save_screenshot(path)
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless
