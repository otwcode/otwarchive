class ReadingsController < ApplicationController
  before_filter :users_only
  before_filter :load_user
  before_filter :check_ownership
  before_filter :check_history_enabled

  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user  
  end
  
  def index
    @readings = @user.readings.paginate(:all, :order => "updated_at DESC", :page => params[:page])
  end

  def destroy
    @reading = @user.readings.find(params[:id])
    @reading.destroy
    flash[:notice] = t('story_deleted', :default => 'Story deleted from your history.')
    redirect_to user_readings_url(current_user)
  end

  protected

  # checks if user has history enabled and redirects to preferences if not, so they can potentially change it
  def check_history_enabled
    unless current_user.preference.history_enabled?
      flash[:notice] = t('reading_disabled', :default => "You have reading history disabled in your preferences. Change it below if you'd like us to keep track of it.")
      redirect_to user_preferences_path(current_user)
    end
  end

end
