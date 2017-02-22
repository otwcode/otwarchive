class AdminSessionsController < ApplicationController
  
  before_filter :user_logout_required
  
  def new  
    @admin_session = AdminSession.new  
  end
  
  def create
    @admin_session = AdminSession.new(params[:admin_session])  
    if @admin_session.save  
      flash[:notice] = "Successfully logged in."  
      redirect_to admin_users_path  
    else  
      flash[:error] = "Authentication failed."
      # redirect instead of render because otherwise you get hints as to whether it was the name or password which failed
      redirect_to :action => 'new'
    end
  end
  
  def destroy
    admin_session = AdminSession.find
    if admin_session
      admin_session.destroy  
      flash[:notice] = "Successfully logged out as admin."
    end
    redirect_to root_path
  end
  
end
