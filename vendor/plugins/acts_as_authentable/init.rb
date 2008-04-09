%w(acts_as_authentable authentable_entity user_authentication admin_authentication).each do |file|
  require file
end

ActionController::Base.send :include, UserAuthentication
ActionController::Base.send :include, AdminAuthentication
ActionController::Base.send :filter_parameter_logging, :password
ActiveRecord::Base.send :include, ActiveRecord::Acts::Authentable
