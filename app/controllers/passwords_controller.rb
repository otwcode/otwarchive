# Use for resetting lost passwords
class PasswordsController < ApplicationController      
  
  def new
  end
  
  def create
    @user = User.find_by_login(params[:login])
    
    if @user 
      @user.reset_user_password
      @user.save
      UserMailer.deliver_reset_password(@user)
      flash[:notice] = 'Check your email for your new password.'
      redirect_to login_path 
    else
      flash[:notice] = 'No Such User.'
      render :action => "new"
    end
  end    
  
end
