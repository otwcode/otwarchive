require "sauce/cucumber"
require "capybara/rails"
require "sauce/connect"

Sauce.config do |c|
  c[:browser] = "Firefox"
  c[:version] = "18"
  c[:os] = "linux"
  c[:start_tunnel] = true
end

