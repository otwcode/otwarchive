# Namespaced Admin class
class Admin
 # Handle admin session authentication
  class SessionsController < Devise::SessionsController
    before_filter :user_logout_required, except: :destroy
    skip_after_filter :store_location
  end
end
