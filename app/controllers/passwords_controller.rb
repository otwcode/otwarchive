# Use for resetting lost passwords
class PasswordsController < ApplicationController      
  
  def new
  end
  
  def create
    @user = User.find_by_login(params[:login])
    @user.reset_user_password

    respond_to do |format|
      if @user.save
        UserMailer.deliver_reset_password(@user)
        flash[:notice] = 'Check your email for your new password.'
        format.html { redirect_to login_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end    
  
end
