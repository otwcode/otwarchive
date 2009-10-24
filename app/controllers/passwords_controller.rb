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
      flash[:notice] = t('check_email', :default => 'Check your email for your new password.') + ' <a href="session/new">' + t('layout.header.sign_in', :default => 'Sign in') + '</a>'
      render :action => "new"
    rescue
      flash[:login] = '<br /><br /><div class="flash notice">' + t('try_again', :default => "We couldn't find an account with that email address or username. Please try again?") + "</div>"
      render :action => "new"
    end
  end    
  
end