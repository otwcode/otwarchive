class AdminsController < ApplicationController
  before_filter :admin_only
  
  def access_denied
    flash[:error] = "Maybe you need to login?"
    store_location
    redirect_to :controller => 'admin_session', :action => 'new'
    false
  end
  
  # GET /admins
  # GET /admins.xml
  def index
    @admins = Admin.find(:all)
  end

  # GET /admins/1
  # GET /admins/1.xml
  def show
    @admin = Admin.find(params[:id])
  end

  # DELETE /admins/1
  # DELETE /admins/1.xml
  def destroy
    @admin = Admin.find(params[:id])
    @admin.destroy
    redirect_to admins_url
  end
end
