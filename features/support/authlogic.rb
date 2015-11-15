require "authlogic/test_case"
World(Authlogic::TestCase)
ApplicationController.skip_before_filter :activate_authlogic
Before do
  activate_authlogic
end
