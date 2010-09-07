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
    flash[:notice] = t('story_deleted', :default => 'Work deleted from your history.')
    redirect_to user_readings_url(current_user)
  end
  
  def clear
    @user.readings.each do |reading|
       begin
         reading.destroy
       rescue
         @errors << t('destroy_multiple.deletion_failed', :default => "There were problems deleting your history.")
       end
     end
    flash[:notice] = t('history_deleted', :default => 'Your history is now cleared.')
    redirect_to user_readings_url(current_user)
  end
  
  # marks a work to read later, or unmarks it if the work is already marked
  def marktoread
    reading = Reading.find(params[:id])
    @work = Work.find(params[:work_id])
      if reading == nil # failsafe
          flash[:error] = t('marktoreadfailed', :default => "Marking a work to read later failed")
      else
        reading.major_version_read, reading.minor_version_read = @work.major_version, @work.minor_version
        if reading.toread?
          reading.toread = false
          flash[:notice] = t('savedtoread', :default => "The work was marked as read.")
        else
          reading.toread = true
          flash[:notice] = t('savedtoread', :default => "The work was marked to read later. You can find it in your history.")
        end
        reading.save
      end
    true
    redirect_to(request.env["HTTP_REFERER"] || root_path)
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
