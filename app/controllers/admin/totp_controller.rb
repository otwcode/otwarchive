class Admin::TotpController < Admin::BaseController
  before_action :require_admin_owner
  before_action :check_totp_disabled, only: [:new, :create]
  before_action :check_totp_enabled, only: [:confirm_disable, :disable_totp]

  def new
    current_admin.generate_otp_secret_if_missing!
    @page_subtitle = t(".page_title")
  end

  def create
    unless current_admin.valid_password?(enable_2fa_params[:password])
      flash[:error] = t("devise.failure.admin.invalid")
      return redirect_to new_admin_totp_path
    end

    if current_admin.validate_and_consume_otp!(enable_2fa_params[:otp_attempt])
      current_admin.enable_otp!

      flash[:notice] = t(".success")
      redirect_to show_backup_codes_admin_totp_path
    else
      flash[:error] = t(".incorrect_code")
      redirect_to new_admin_totp_path
    end
  end

  def show_backup_codes
    unless current_admin.otp_required_for_login
      flash[:error] = t(".not_enabled")
      return redirect_to new_admin_totp_path
    end

    if current_admin.otp_backup_codes_generated?
      flash[:error] = t(".already_seen")
      return redirect_to admins_path
    end

    @page_subtitle = t(".page_title")
    @backup_codes = current_admin.generate_otp_backup_codes!
    current_admin.save!
  end

  def confirm_disable
    @page_subtitle = t(".page_title")
  end

  def disable_totp
    unless current_admin.valid_password?(enable_2fa_params[:password])
      flash[:error] = t("devise.failure.admin.invalid")
      return redirect_to confirm_disable_admin_totp_path
    end

    unless current_admin.validate_and_consume_otp!(enable_2fa_params[:otp_attempt])
      flash[:error] = t(".incorrect_code")
      return redirect_to confirm_disable_admin_totp_path
    end

    if current_admin.disable_otp!
      flash[:notice] = t(".success")
    else
      flash[:error] = t(".failure")
    end

    redirect_to admins_path
  end

  private

  def check_totp_enabled
    return if current_admin.otp_required_for_login

    flash[:error] = t("admin.totp.already_disabled")
    redirect_to admins_path
  end

  def check_totp_disabled
    return unless current_admin.otp_required_for_login

    flash[:error] = t("admin.totp.already_enabled")
    redirect_to admins_path
  end

  def enable_2fa_params
    params.require(:admin).permit(:otp_attempt, :password)
  end
end
