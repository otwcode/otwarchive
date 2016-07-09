# Namespaced Admin class
class Admin
  # Handle admin session authentication
  class SessionsController < Devise::SessionsController
    before_filter :user_logout_required
    skip_before_filter :store_location
  end

  # Overwrite default Devise redirect after sign in
  def after_sign_in_path_for(_resource)
    admin_users_path
  end
end
