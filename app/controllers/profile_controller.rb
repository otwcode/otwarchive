class ProfileController < ApplicationController
  
  def show
    @user = User.find_by_login(params[:user_id])
    if @user.nil?
      flash[:error] = t('invalid_user', :default => "Sorry, there's no user by that name.")
      redirect_to '/'
    elsif @user.profile.nil?
      Profile.create(:user_id => @user.id)
      @user.reload
    end
  end
  
end
