class UsersController < ApplicationController
  before_filter :check_user_status, :only => [:edit, :update]

  # checks if the current user and the given user are the same
  def is_user?(user)
    current_user == user
  end
  
  def index
    @users = User.alphabetical.paginate(:page => params[:page])
  end 

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find_by_login(params[:id])
    @works = @user.works.visible(current_user, {:limit => 5, :order => 'works.updated_at DESC'})
    @series = @user.series.find(:all, :limit => 5, :order => 'series.updated_at DESC')
    @bookmarks = @user.bookmarks.visible(current_user, {:limit => 5, :order => 'bookmarks.updated_at DESC'})
  end
  
  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
  end
  
  # GET /users/1/edit
  def edit
    @user = User.find_by_login(params[:id])
    unless is_user?(@user)
      flash[:error] = "You are not allowed to perform this action.".t
      redirect_to user_url(@user)
    end
  end
  
  # POST /users
  # POST /users.xml
  def create
    if params["cancel-create-account"] == "Cancel"
      redirect_to '/'
    else
      @user = User.new(params[:user])   
      if @user.save
        flash[:notice] = 'during testing you can activate via <a href=' + activate_path(@user.activation_code) + '>your activation url</a>.'
  
        render :partial => "confirmation", :layout => "application"
      else
        render :action => "new"
      end
    end
  end
  
  def activate
    if params[:id].blank?
      flash[:error] = "Your activation key is missing.".t
      redirect_to ''
    else
      @user = User.find_by_activation_code(params[:id])
      if @user
        @user.activate
        self.current_user = @user
        flash[:notice] = "Signup complete! This is your public profile.".t
        redirect_to(@user)
      else
        flash[:error] = "Your activation key is invalid. Perhaps it has expired.".t
        redirect_to '' 
      end
    end
  end
  
  def after_reset
    @user = User.find_by_login(params[:id])  
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find_by_login(params[:id])
    
    if !is_user?(@user)
      flash[:error] = "You are not allowed to perform this action.".t
      redirect_to user_url(@user)
    else

      begin 
        if @user.profile
          @user.profile.update_attributes! params[:profile_attributes]
        else
          @user.profile = Profile.new(params[:profile_attributes])
          @user.profile.save!
        end
        if @user.preference
          @user.preference.update_attributes! params[:preference_attributes]
        else
          @user.preference = Preference.new(params[:preference_attributes])
          @user.preference.save!
        end
        @user.recently_reset = nil if params[:change_password] 
        @user.update_attributes!(params[:user]) 
        flash[:notice] = 'User was successfully updated.'.t
        redirect_to(@user) 
      rescue
        render :action => "edit"
      end
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find_by_login(params[:id])
    if !is_user?(@user)
      flash[:error] = "You are not allowed to perform this action.".t
      redirect_to user_url(@user)
    else
      @user.destroy
    
      redirect_to(users_url) 
    end
  end
  
  
end
