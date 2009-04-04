# Use for resetting lost passwords
class PasswordsController < ApplicationController      
  layout "session"
  
  def new
  end
  
  def create
    begin
      @user = User.find_by_login(params[:login]) || User.find_by_email(params[:login])
      @user.reset_user_password
      @user.save
      UserMailer.deliver_reset_password(@user)
      flash[:notice] = t('check_email', :default => 'Check your email for your new password.')
      redirect_to login_path 
    rescue
      flash[:login] = t('try_again', :default => "We couldn't find an account with that email address or username. Please try again?")
      render :action => "new"
    end
  end    
  
end