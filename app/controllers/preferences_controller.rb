class PreferencesController < ApplicationController
  before_filter :is_owner
  
  # Ensure that the current user is authorized to view and change this information
  def is_owner
    @user = User.find_by_login(params[:user_id])
    @user == current_user || access_denied
  end
  
  def index
    @user = User.find_by_login(params[:user_id])
    @preference = @user.preference
  end

  def update
    @user = User.find_by_login(params[:user_id])
    @preference = @user.preference
    @user.preference.attributes = params[:preference]
    if @user.preference.save
      flash[:notice] = 'Your preferences were successfully updated.'.t
      redirect_to user_preferences_path(@user) 
    else
      render :action => :index
    end
  end
end
