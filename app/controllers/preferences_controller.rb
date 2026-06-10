class PreferencesController < ApplicationController
  before_action :load_user
  before_action :check_ownership_or_admin

  # Ensure that the current user is authorized to view and change this information
  def load_user
    @user = User.find_by!(login: params[:user_id])
    @check_ownership_of = @user
  end

  def index
    @page_subtitle = t(".page_title", username: @user.login)
    @preference = @user.preference
    authorize @preference if logged_in_as_admin?
    @available_skins = available_skins
    @available_locales = Locale.where(email_enabled: true)
  end

  def update
    @preference = @user.preference
    authorize @preference if logged_in_as_admin?
    @available_skins = available_skins
    @available_locales = Locale.where(email_enabled: true)

    @user.preference.attributes = permitted_attributes(@preference)
    
    if params[:preference][:skin_id].present?
      # unset session skin if user changed their skin
      session[:site_skin] = nil
    end

    if @user.preference.save
      flash[:notice] = t(".success")
      redirect_to user_path(@user)
    else
      flash[:error] = t(".error")
      render action: :index
    end
  end

  private

  def available_skins
    (@user.skins.site_skins.usable +
    Skin.approved_skins.site_skins.usable).uniq
  end
end
