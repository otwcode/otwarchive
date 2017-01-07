# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

# This file has been edited by hand :(
require 'yaml'
require 'selenium/webdriver'
require 'capybara/cucumber'
require 'browserstack/local'
require 'simplecov'
require 'coveralls'
require 'capybara/poltergeist'
SimpleCov.command_name "features-" + (ENV['TEST_RUN'] || 'local')
Coveralls.wear_merged!('rails') unless ENV['TEST_LOCAL']
require 'cucumber/rails'
require 'email_spec'
require 'email_spec/cucumber'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')

# Produce a screen shot for each failure
require 'capybara-screenshot/cucumber'

# Browser stack:
class Capybara::Selenium::Driver < Capybara::Driver::Base
  def reset!
    if @browser
      @browser.navigate.to('about:blank')
    end
  end
end

Capybara.server_port = 8080
Capybara.asset_host = "http://localhost:#{Capybara.server_port}"
Capybara.always_include_port = true

TASK_ID = (ENV['TASK_ID'] || 0).to_i
CONFIG_NAME = ENV['CFG_NAME'].nil? ? "" : ENV['CFG_NAME']

CONFIG = YAML.load(File.read(File.join(File.dirname(__FILE__), "../../config/browserstack#{CONFIG_NAME}.config.yml")))
CONFIG['user'] = ENV['BROWSERSTACK_USERNAME'] || CONFIG['user']
CONFIG['key'] = ENV['BROWSERSTACK_ACCESS_KEY'] || CONFIG['key']
@hardware = CONFIG['browser_caps'][0]['device']

Capybara.register_driver :browserstack do |app|
  @caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID])
  @caps['browserstack.local'] = 'true' if ENV['BROWSERSTACK_ACCESS_KEY']

  # Code to start browserstack local before start of test
  if @caps['browserstack.local'] && @caps['browserstack.local'].to_s == 'true'; 
    @bs_local = BrowserStack::Local.new
    bs_local_args = {"key" => "#{CONFIG['key']}"}
    @bs_local.start(bs_local_args)
  end

  Capybara::Selenium::Driver.new(app,
    :browser => :remote,
    :url => "http://#{CONFIG['user']}:#{CONFIG['key']}@#{CONFIG['server']}/wd/hub",
    :desired_capabilities => @caps
  )
end

# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#

ActionController::Base.allow_rescue = false

# Config options for Capybara, including increased timeout to minimise failures on CI servers
# ring-fence with if ENV['CI'] if this becomes a problem locally
Capybara.configure do |config|
  config.match = :prefer_exact
  config.ignore_hidden_elements = false
  config.default_max_wait_time = 25
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :poltergeist

@javascript = false
@browserstack = false
Before '@javascript' do
  @javascript = true
  @browserstack = false
end

Capybara::Screenshot.autosave_on_failure = true
Before '@browserstack' do
  @browserstack = true
  @javascript = false
  Capybara.javascript_driver = :browserstack
  Capybara::Screenshot.autosave_on_failure = false
  page.driver.browser.manage.window.maximize if @hardware.blank?
  puts "\n\nmaximise\n\n" if @hardware.blank?
  puts CONFIG['browser_caps']
end

Before '@disable_caching' do
  ActionController::Base.perform_caching = false
end

After '@disable_caching' do
  ActionController::Base.perform_caching = true
end

# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :transaction

# Code to stop browserstack local after end of test
at_exit do
  @bs_local.stop unless @bs_local.nil? 
end
