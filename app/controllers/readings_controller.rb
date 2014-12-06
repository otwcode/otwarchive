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
    @readings = @user.readings
    @page_subtitle = ts("History")
    @kudos_list = []
    if params[:show] == 'to-read'
      @readings = @readings.where(:toread => true)
      @page_subtitle = ts("Saved For Later")
    end
    if params[:show] == 'kudos-history'
      # collext a list of pseuds the user may have left kudos under
      pseuds=Pseud.where(user_id: @user.id ).map { |x| x.id }
      @kudos_list = Kudo.where(:pseud_id => pseuds ).map{ |w| w.commentable_id }
      @readings = @readings.where(:work_id => @kudos_list)
      @page_subtitle = ts("Kudos history")
    end
    @readings = @readings.order("last_viewed DESC").page(params[:page])
  end

  def destroy
    @reading = @user.readings.find(params[:id])
    @reading.destroy
    flash[:notice] = ts("Work deleted from your history.")
    redirect_to user_readings_url(current_user)
  end

  def clear
    @user.readings.each do |reading|
       begin
         reading.destroy
       rescue
         @errors << ts("There were problems deleting your history.")
       end
     end
    flash[:notice] = ts("Your history is now cleared.")
    redirect_to user_readings_url(current_user)
  end

  protected

  # checks if user has history enabled and redirects to preferences if not, so they can potentially change it
  def check_history_enabled
    unless current_user.preference.history_enabled?
      flash[:notice] = ts("You have reading history disabled in your preferences. Change it below if you'd like us to keep track of it.")
      redirect_to user_preferences_path(current_user)
    end
  end

end
