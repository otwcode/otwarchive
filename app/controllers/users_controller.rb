class UsersController < ApplicationController
  
  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find_by_login(params[:id])
  end
  
  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
  end
  
  # GET /users/1/edit
  def edit
    @user = User.find_by_login(params[:id])
  end
  
  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])   
    @user.profile = Profile.new
    @user.preference = Preference.new
    unless !ArchiveConfig.USE_OPENID || params[:user][:identity_url].blank?
      @user.identity_url = OpenIdAuthentication.normalize_url(@user.identity_url)
    end
    @user.pseuds << Pseud.new(:name => @user.login, :description => "Default pseud".t, :is_default => :true)
    
    if @user.save
      flash[:notice] = 'during testing you can activate via <a href=' + activate_path(@user.activation_code) + '>your activation url</a>.'

      render :partial => "confirmation", :layout => "application"
    else
      render :action => "new"
    end
  end
  
  def activate
    if params[:id].blank?
      flash[:error] = "Your activation key is missing."
      redirect_to ''
    else
      @user = User.find_by_activation_code(params[:id])
      if @user
        @user.activate
        flash[:notice] = "Signup complete! This is your public profile. Please log in to edit it."
        redirect_to(@user)
      else
        flash[:error] = "Your activation key is invalid. Perhaps it has expired."
        redirect_to '' 
      end
    end
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find_by_login(params[:id])
    
    if @user.profile
      @user.profile.update_attributes params[:profile_attributes]
    else
      @user.profile = Profile.new(params[:profile_attributes])
    end
    
    if @user.preference
      @user.preference.update_attributes params[:preference_attributes]
    else
      @user.preference = Preference.new(params[:preference_attributes])
    end
    
    if @user.update_attributes(params[:user]) && @user.profile.update_attributes(params[:profile_attributes])
      flash[:notice] = 'User was successfully updated.'
      unless !ArchiveConfig.USE_OPENID || params[:user][:identity_url].blank?
        @user.identity_url = OpenIdAuthentication.normalize_url(@user.identity_url)
      end
      redirect_to(@user) 
    else
      render :action => "edit"
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find_by_login(params[:id])
    @user.destroy
    
    redirect_to(users_url) 
  end
  
  
end
