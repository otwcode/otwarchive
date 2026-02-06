class ReadingsController < ApplicationController
  before_action :users_only
  before_action :load_user
  before_action :check_ownership
  before_action :check_history_enabled

  def load_user
    @user = User.find_by(login: params[:user_id])
    @check_ownership_of = @user
  end

  def index
    @readings = @user.readings.visible
    @page_subtitle = t(".history_page_title")
    if params[:show] == 'to-read'
      @readings = @readings.where(toread: true)
      @page_subtitle = t(".marked_for_later_page_title")
    end
    @readings = @readings.order("last_viewed DESC")
    @pagy, @readings = pagy(@readings)
  end

  def destroy
    @reading = @user.readings.find(params[:id])
    if @reading.destroy
      success_message = ts('Work successfully deleted from your history.')
      respond_to do |format|
        format.html { redirect_back_or_to(user_readings_path(current_user, page: params[:page]), notice: success_message) }
        format.json { render json: { item_success_message: success_message }, status: :ok }
      end
    else
      respond_to do |format|
        format.html do
          flash.keep
          redirect_back_or_to(user_readings_path(current_user, page: params[:page]), flash: { error: @reading.errors.full_messages })
        end
        format.json { render json: { errors: @reading.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def clear
    success = true

    @user.readings.each do |reading|
      reading.destroy!
    rescue ActiveRecord::RecordNotDestroyed
      success = false
    end

    if success
      flash[:notice] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to user_readings_path(current_user)
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
