class PreferencesController < ApplicationController
  before_filter :load_user
  before_filter :check_ownership
  
  # Ensure that the current user is authorized to view and change this information
  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user
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
      flash[:notice] = t('successfully_updated', :default => 'Your preferences were successfully updated.')
      redirect_to user_preferences_path(@user) 
    else
      flash[:error] = t('failed_update', :default => 'Sorry, something went wrong. Please try that again.')
      render :action => :index
    end
  end
end
