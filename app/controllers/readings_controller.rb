class ReadingsController < ApplicationController
  before_filter :users_only
  before_filter :history_enabled?

  def access_denied
    flash[:error] = t('errors.please_log_in', :default => "Please log in first.")
   store_location
    redirect_to new_session_path
    false
  end
  
  def index
    @user = User.find_by_login(params[:user_id])
    @readings = current_user.readings.paginate(:all, :order => "updated_at DESC", :page => params[:page])
  end

  def show
    @user = User.find_by_login(params[:user_id]) 
    @reading = current_user.readings.find(params[:id], :options => {:order => :updated_at})
  end

  def destroy
    @reading = current_user.readings.find(params[:id])
    @reading.destroy
    flash[:notice] = t('notices.readings.story_deleted', :default => 'Story deleted from your history.')
   redirect_to user_readings_url(current_user)
  end

  protected
  # checks if user has history enabled and redirects to profile if not
  def history_enabled?
    current_user.preference.history_enabled || history_disabled_go_to_profile
  end

  # redirects user back to profile and shows message that history is disabled
  def history_disabled_go_to_profile
    flash[:notice] = t('notices.readings.reading_disabled', :default => "You have reading history disabled in your preferences.")
   redirect_to user_path(current_user)
  end

end
