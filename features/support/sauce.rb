require "sauce/cucumber"
require "capybara/rails"
require "sauce/connect"

Capybara.default_driver = :sauce
Capybara.server_port = 49221
Sauce.config do |c|
  c[:browser] = "Firefox"
  c[:version] = "18"
  c[:os] = "linux"
  c[:start_tunnel] = false
end

