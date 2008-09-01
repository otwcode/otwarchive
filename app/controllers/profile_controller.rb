class ProfileController < ApplicationController
  
  def show
    @user = User.find_by_login(params[:user_id])
    @hide_dashboard = true
  end
  
end
