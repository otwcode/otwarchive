class User
  # Handle user session authentication
  class SessionsController < Devise::SessionsController
    layout 'session'
    before_filter :admin_logout_required, except: :destroy
    skip_before_filter :store_location

    # Devise destroy the whole session, so we need to store the
    # return path and pass if after the session is destroyed
    def destroy
      return_to = session[:return_to]
      super do
        session[:return_to] = return_to
      end
    end
  end
end
