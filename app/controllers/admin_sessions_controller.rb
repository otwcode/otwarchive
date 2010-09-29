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
      render :action => 'new'  
    end
  end
  
  def destroy
    @admin_session = AdminSession.find  
    @admin_session.destroy  
    flash[:notice] = "Successfully logged out."  
    redirect_to root_path
  end
  
end
