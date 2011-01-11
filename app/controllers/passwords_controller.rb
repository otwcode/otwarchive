# Use for resetting lost passwords
class PasswordsController < ApplicationController      
  skip_before_filter :store_location
  layout "session"
  
  def new
  end
  
  def create
    @user = User.find_by_login(params[:login]) || User.find_by_email(params[:login])
    if @user.nil?
      flash[:login] = '<br /><br /><div class="flash notice">'.html_safe + 
                      t('try_again', :default => "We couldn't find an account with that email address or username. Please try again?") + 
                      "</div>".html_safe
      render :action => "new"
    else
      @user.reset_user_password
      @user.save
      @user_session = UserSession.find  
      if @user_session
        @user_session.destroy 
      end
      UserMailer.reset_password(@user).deliver
      flash[:notice] = t('check_email', :default => 'Check your email for your new password.')
      redirect_to login_path
    end
  end    
  
end
