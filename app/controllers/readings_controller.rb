class ReadingsController < ApplicationController
  before_filter :users_only
  before_filter :history_enabled?

  def access_denied
    flash[:error] = "Please log in first.".t
    store_location
    redirect_to new_session_path
    false
  end
  
  def index
    @user = User.find_by_login(params[:user_id])
    @readings = current_user.readings.paginate(:all, :order => "updated_at DESC", :page => params[:page])
    @tag_categories = TagCategory.official
  end

  def show
    @user = User.find_by_login(params[:user_id]) 
    @reading = current_user.readings.find(params[:id], :options => {:order => :updated_at})
    @tag_categories = TagCategory.official
  end

  def destroy
    @reading = current_user.readings.find(params[:id])
    @reading.destroy
    flash[:notice] = 'Story deleted from your history.'.t
    redirect_to user_readings_url(current_user)
  end

  protected
  # checks if user has history enabled and redirects to profile if not
  def history_enabled?
    current_user.preference.history_enabled || history_disabled_go_to_profile
  end

  # redirects user back to profile and shows message that history is disabled
  def history_disabled_go_to_profile
    flash[:notice] = "You have reading history disabled in your preferences.".t
    redirect_to user_path(current_user)
  end

end
