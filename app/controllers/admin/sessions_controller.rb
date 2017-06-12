# Namespaced Admin class
class Admin
 # Handle admin session authentication
  class SessionsController < Devise::SessionsController
    before_action :user_logout_required, except: :destroy
    skip_after_action :store_location, raise: false
  end
end
