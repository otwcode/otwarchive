# Handles admin logins
class Admin::SessionController < ApplicationController
  
  # Prevents multiple logins for people with both user and admin accounts
  before_filter :user_logout_required

  def new
  end
  
  def create
    self.current_admin = Admin.authenticate(params[:login], params[:password])
    if logged_in_as_admin?
      redirect_back_or_default(works_path)
      flash[:notice] = "Logged in successfully"
    else
      flash[:notice] = "Authentication failed."
      render :action => 'new'
      end
  end

  def destroy
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to new_admin_session_path
  end
end