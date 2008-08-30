class Admin::AdminUsersController < ApplicationController
  
  before_filter :admin_only

  def index
    @users = User.alphabetical.paginate(:page => params[:page])
  end 

  # GET admin/users/1
  # GET admin/users/1.xml
  def show
    @user = User.find_by_login(params[:id])
  end

  # GET admin/users/1/edit
  def edit
    @user = User.find_by_login(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  # PUT admin/users/1
  # PUT admin/users/1.xml
  def update
    @user = User.find_by_login(params[:user][:login])
    @user.attributes = params[:user]
    if @user.save(false)
      flash[:notice] = 'User was successfully updated.'
      redirect_to(admin_users_url) 
    else
      render :action => "edit"
    end
  end

  # DELETE admin/users/1
  # DELETE admin/users/1.xml
  def destroy
    @user = User.find_by_login(params[:id])
    @user.destroy
    redirect_to(admin_users_url) 
  end

end  

