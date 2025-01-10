class ProfileController < ApplicationController
  before_action :load_user_and_pseuds

  def show
    @user = User.find_by(login: params[:user_id])
    if @user.profile.nil?
      Profile.create(user_id: @user.id)
      @user.reload
    end

    @profile = ProfilePresenter.new(@user.profile)
    #code the same as the stuff in users_controller
    if current_user.respond_to?(:subscriptions)
      @subscription = current_user.subscriptions.where(subscribable_id: @user.id,
                                                       subscribable_type: 'User').first ||
                      current_user.subscriptions.build(subscribable: @user)
    end
    @page_subtitle = ts("%{username} - Profile", username: @user.login)
  end

  def pseuds
    respond_to do |format|
      format.html do
        redirect_to user_pseuds_path(@user)
      end

      format.js
    end
  end

  private

  def load_user_and_pseuds
    @user = User.find_by(login: params[:user_id])

    if @user.nil?
      flash[:error] = ts("Sorry, there's no user by that name.")
      redirect_to root_path
      return
    end

    @pseuds = @user.pseuds.default_alphabetical.paginate(page: params[:page])
  end
end
