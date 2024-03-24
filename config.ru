# This file is used by Rack-based servers to start the application.

require_relative "config/environment"
require "resque/server"
require "resque/scheduler/server"

# Set the AUTH env variable to your basic auth password to protect Resque.
AUTH_PASSWORD = ENV['AUTH']
if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD
  end
end

run Rack::URLMap.new \
  "/" => Otwarchive::Application,
  "/resque" => Resque::Server
