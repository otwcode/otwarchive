class ProfileController < ApplicationController
  before_action :load_user_and_pseuds
  before_action :check_user_status, only: [:edit, :update]
  before_action :check_ownership_or_admin, only: [:edit, :update]

  def show
    @user = User.find_by(login: params[:user_id])
    if @user.profile.nil?
      Profile.create(user_id: @user.id)
      @user.reload
    end

    @profile = @user.profile

    # code the same as the stuff in users_controller
    if current_user.respond_to?(:subscriptions)
      @subscription = current_user.subscriptions.where(subscribable_id: @user.id,
                                                       subscribable_type: "User").first ||
                      current_user.subscriptions.build(subscribable: @user)
    end
    @page_subtitle = t(".page_title", username: @user.login)
  end

  # GET /users/1/profile/edit
  def edit
    @page_subtitle = t(".browser_title")
    authorize @user.profile if logged_in_as_admin?
  end

  def pseuds
    respond_to do |format|
      format.html do
        redirect_to user_pseuds_path(@user)
      end

      format.js
    end
  end

  def update
    authorize @user.profile if logged_in_as_admin?
    if @user.profile.update(profile_params)
      if logged_in_as_admin? && @user.profile.ticket_url.present?
        link = view_context.link_to("Ticket ##{@user.profile.ticket_number}", @user.profile.ticket_url)
        AdminActivity.log_action(current_admin, @user, action: "edit profile", summary: link)
      end
      flash[:notice] = t(".success")
      redirect_to user_profile_path(@user)
    else
      render :edit
    end
  end

  private

  def load_user_and_pseuds
    @user = User.find_by(login: params[:user_id])
    @check_ownership_of = @user

    if @user.nil?
      flash[:error] = ts("Sorry, there's no user by that name.")
      redirect_to root_path
      return
    end

    @pseuds = @user.pseuds.default_alphabetical.paginate(page: params[:page])
  end

  def profile_params
    params.require(:profile).permit(
      :title, :about_me, :ticket_number
    )
  end
end
