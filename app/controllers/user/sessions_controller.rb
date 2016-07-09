class User
  # Handle user session authentication
  class SessionsController < Devise::SessionsController
    layout 'session'
    before_filter :admin_logout_required
    skip_before_filter :store_location
  end
end
