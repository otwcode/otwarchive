module AdminAuthentication
  protected
    # Returns true or false if the admin is logged in.
    # Preloads @current_admin with the admin model if they're logged in.
    def logged_in_as_admin?
      current_admin != :false
    end
    
    # Accesses the current admin from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.
    def current_admin
      @current_admin ||= (admin_login || :false)
    end
    
    # Store the given admin in the session.
    def current_admin=(new_admin)
      session[:admin] = (new_admin.nil? || new_admin.is_a?(Symbol)) ? nil : new_admin.id
      @current_admin = new_admin
    end

    # Filter method - keeps users out of admin areas
    def admin_only
      logged_in_as_admin? || access_denied
    end
    
    # Filter method - prevents users from logging in with more than one kind of account at once
    def user_logout_required
      if logged_in?
        flash[:notice] = 'Please log out of your user account first!'
        # Add a logical redirect here
      end
    end
    
    # Inclusion hook to make #current_admin and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_admin, :logged_in_as_admin?
    end

    # Called from #current_admin. Login by the admin id stored in the session.
    def admin_login
      self.current_admin = Admin.find_by_id(session[:admin]) if session[:admin]
    end
end
