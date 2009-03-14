# Use for resetting lost passwords
class PasswordsController < ApplicationController      
  layout "session"
  
  def new
  end
  
  def create
    if params[:login]
      @user = User.find_by_login(params[:login]) || User.find_by_email(params[:login])
    end
       
    if @user 
      @user.reset_user_password
      @user.save
      UserMailer.deliver_reset_password(@user)
      flash[:notice] = t('notices.passwords.check_email', :default => 'Check your email for your new password.')
     redirect_to login_path 
    else
      flash[:login] = t('errors.passwords.try_again', :default => "We couldn't find an account with that email address or username. Please try again?") + "<br />"
      render :action => "new"
    end
  end    
  
end
