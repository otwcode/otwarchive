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
      flash[:notice] = t('notices.preferences.successfully_updated', :default => 'Your preferences were successfully updated.')
      redirect_to user_preferences_path(@user) 
    else
      flash[:error] = t('errors.preferences.failed_update', :default => 'Sorry, something went wrong. Please try that again.')
      render :action => :index
    end
  end
end
