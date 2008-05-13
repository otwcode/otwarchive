# Use for resetting lost passwords
class PasswordsController < ApplicationController      
  
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
      flash[:notice] = 'Check your email for your new password.'
      redirect_to login_path 
    else
      flash[:error] = 'No Such User.'
      render :action => "new"
    end
  end    
  
end
