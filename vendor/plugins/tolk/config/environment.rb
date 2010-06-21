RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'

  config.action_controller.session = {
    :session_key => '_tolk_session',
    :secret      => 'f2d72b63242db79df080031c60159a419981cc6c066e961405c1a86c5c38ba56c960d6de171dc4cf985f1544c00466400abf0aac2ce1cbdb726f6127d304fb07'
  }
end

$KCODE = 'UTF8'
require 'ya2yaml'
