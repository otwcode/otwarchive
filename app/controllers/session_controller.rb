# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController
  
  # Prevents multiple logins for people with both user and admin accounts
  before_filter :admin_logout_required
  skip_before_filter :store_location
  
  def new
    if logged_in?
      redirect_to current_user
    end
    @restricted = true if params[:restricted]
  end
  
  def create
    if ArchiveConfig.USE_OPENID && using_open_id?
      open_id_authentication(params[:openid_url])
    else
      password_authentication(params[:login], params[:password])
    end
  end
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = t('notices.session.logged_out', :default => "You have been logged out.")
   # During testing, logout redirects to the feedback page.
    # Code commented out below would be default when out of testing. 
    ##   redirect_back_or_default('/')
    redirect_to :controller => "feedbacks", :action => "new"
  end

  # switches to the openid version of the login form
  def openid
  end
 
  # switches to the password version of the login form
  def passwd
  end

  # switches to the openid version of the mini login box
  def openid_small
  end
 
  # switches to the password version of the mini login box
  def passwd_small
  end

  protected
  
  def open_id_authentication(openid_url)
    authenticate_with_open_id(openid_url) do |result, identity_url, registration|
      if result.successful?
        @user = User.find_by_identity_url(identity_url)
        if @user
          self.current_user = @user
          successful_login
        else
          failed_login t('errors.session.open_id_failure', :default => "We couldn't find that url in our database. Please try again.")
       end
      else
        failed_login result.message
      end
    end
  end
  
  def password_authentication(login, password)
    self.current_user = User.authenticate(login, password)
    if logged_in?
      successful_login
    else
      if user = User.find_by_login(login)
        if user.activated_at 
          message = t('errors.session.wrong_password', :default => "The password you entered doesn't match our records. Please try again or click the 'forgot password' link below.")
       else
          message = t('errors.session.not_activated', :default => "You'll need to activate your account before you can log in. Please check your email or contact an admin.")
       end
      else 
        message = t('errors.session.wrong_name', :default => "We couldn't find that name in our database. Please try again.")
     end
      failed_login(message)
    end
  end
  
  def failed_login(message = t('errors.session.failed_login', :default => "Sorry, something went wrong! Please try again."))
    flash.now[:error] = message
    render :action => 'new'
  end
  
  def successful_login
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    self.current_user.recently_reset? ? 
        (redirect_to :controller => 'users', :action => 'after_reset', :id => self.current_user.login) : 
        redirect_back_or_default(current_user)
    flash[:notice] = t('notices.logged_in', :default => "Logged in successfully")
 end
end
