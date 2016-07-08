class AdminsController < ApplicationController
  before_filter :authenticate_admin!
  
  # GET /admins
  # GET /admins.xml
  def index
    @admins = Admin.all
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
