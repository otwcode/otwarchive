
require File.join(File.dirname(__FILE__), 'boot')
require 'action_controller'

Rails::Initializer.run do |config|
  if ActionController::Base.respond_to? 'session='
    config.action_controller.session = {:session_key => '_app_session', :secret => '22cde4d5c1a61ba69a81795322cde4d5c1a61ba69a817953'}
  end
  
  config.load_paths << "#{RAILS_ROOT}/app/models/person" # moduleless model path
end

# Dependencies.log_activity = true
