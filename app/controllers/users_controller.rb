class UsersController < ApplicationController
  
  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
  end
  
  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
  end
  
  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end
  
  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])   
    @user.profile = Profile.new
    
    unless params[:user][:identity_url].blank?
      @user.identity_url = OpenIdAuthentication.normalize_url(@user.identity_url)
    end
    @user.pseuds << Pseud.new(:name => @user.login, :description => "Default pseud".t, :is_default => :true)
    
    if @user.save
      flash[:error] = 'Mailing currently is not working, so instead please use <a href=' + activate_path(@user.activation_code) + '>your activation url</a>.'
      render :partial => "confirmation", :layout => "application"
    else
      render :action => "new"
    end
  end
  
  def activate
    self.current_user = params[:id].blank? ? :false : User.find_by_activation_code(params[:id])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_to :action => :show, :id => current_user.id
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    
    if @user.profile
      @user.profile.update_attributes params[:profile_attributes]
    else
      @user.profile = Profile.new(params[:profile_attributes])
    end
    
    if @user.update_attributes(params[:user]) && @user.profile.update_attributes(params[:profile_attributes])
      flash[:notice] = 'User was successfully updated.'
      redirect_to(@user) 
    else
      render :action => "edit"
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    
    redirect_to(users_url) 
  end
  
  
end
