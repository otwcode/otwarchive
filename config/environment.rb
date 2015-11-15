# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Otwarchive::Application.initialize!

# http://stackoverflow.com/questions/5270835/authlogic-activation-problems
# After updatign authlogic
Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::RailsAdapter.new(self)
