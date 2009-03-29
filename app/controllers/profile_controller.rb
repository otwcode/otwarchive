class ProfileController < ApplicationController
  
  def show
    @user = User.find_by_login(params[:user_id])
    @hide_dashboard = true
    if @user.nil?
      flash[:error] = t('invalid_user', :default => "Sorry, there's no user by that name.")
      redirect_to '/'
    elsif @user.profile.nil?
      flash[:error] = t('no_profile', :default => "Sorry, there's no profile for this user.")
      redirect_to @user      
    end
  end
  
end
