# features/support/sauce.rb

if ENV['TRAVIS']

  require 'sauce/cucumber'
  require 'sauce/parallel'
  require "capybara/rails"
  require "sauce/connect"

  Capybara.run_server = false
  Capybara.register_driver(:selenium){ |app| Capybara::Selenium::Driver.new(app, { :browser => :chrome }) }
  Capybara.default_driver = :selenium
  Capybara.javascript_driver = :sauce
  Capybara.server_port = 80

  Sauce.config do |c|

    if ENV['USE_TUNNEL']
      start_tunnel_for_parallel_tests(c)
    end

    platform, name, version = ENV["BROWSER"].split(',')
    c[:browsers] = [[platform, name, version]]
  end

  Around do |scenario, block|
    Sauce::Capybara::Cucumber.around_hook scenario, block
  end

end