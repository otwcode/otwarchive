# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController
  
  # Prevents multiple logins for people with both user and admin accounts
  # before_filter :admin_logout_required
  
  def new
    if logged_in?
      redirect_to :controller => 'works', :action => 'index'
    end
  end
  
  def create
    if using_open_id?
      open_id_authentication(params[:openid_url])
    else
      password_authentication(params[:login], params[:password])
    end
  end
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
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
          failed_login
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
      failed_login
    end
  end
  
  def failed_login(message = "Authentication failed.")
    flash.now[:error] = message
    render :action => 'new'
  end
  
  def successful_login
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    #redirect_back_or_default('/')
    redirect_to :controller => 'works', :action => 'index'
    flash[:notice] = "Logged in successfully"
  end
end
