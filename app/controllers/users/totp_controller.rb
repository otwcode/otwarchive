class Users::TotpController < ApplicationController
  before_action :load_user
  before_action :check_ownership_or_admin
  before_action :check_totp_disabled, only: [:new, :reauthenticate_create, :create]
  before_action :check_totp_enabled, only: [:confirm_disable, :disable]

  def load_user
    @user = User.find_by!(login: params[:user_id])
    @check_ownership_of = @user
  end

  def new
    @page_subtitle = t(".page_title")
  end

  def reauthenticate_create
    unless current_user.valid_password?(params[:password_check])
      flash[:error] = t(".incorrect_password")
      redirect_to new_user_totp_path and return
    end

    current_user.generate_totp_secret_if_missing!
    @page_subtitle = t(".page_title")
  end

  def create
    if current_user.validate_and_consume_otp!(params[:totp_attempt])
      current_user.enable_totp!

      flash[:notice] = t(".success")
      redirect_to show_backup_codes_user_totp_path
    else
      flash.now[:error] = t(".incorrect_code")
      render action: :new and return
    end
  end

  def show_backup_codes
    unless current_user.totp_enabled?
      flash[:error] = t(".not_enabled")
      redirect_to new_user_totp_path and return
    end

    @page_subtitle = t(".page_title")
    @backup_codes = current_user.generate_otp_backup_codes!
    current_user.save!
  end

  def confirm_disable
    @page_subtitle = t(".page_title")
  end

  def disable
    unless current_user.valid_password?(params[:password_check])
      flash.now[:error] = t(".incorrect_password")
      render action: :confirm_disable and return
    end

    if current_user.disable_totp!
      flash[:notice] = t(".success")
    else
      flash[:error] = t(".failure")
    end

    redirect_to user_preferences_path
  end

  private

  def require_user_owner
    return if params[:user_id] == current_user.login

    flash[:error] = t("users.totp.access.permission_denied_generic")
    redirect_to root_path
  end

  def check_totp_enabled
    return if current_user.totp_enabled?

    flash[:error] = t("users.totp.already_disabled")
    redirect_to user_preferences_path
  end

  def check_totp_disabled
    return unless current_user.totp_enabled?

    flash[:error] = t("users.totp.already_enabled")
    redirect_to user_preferences_path
  end
end
