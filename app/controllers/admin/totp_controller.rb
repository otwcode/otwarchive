class Admin::TotpController < Admin::BaseController
  before_action :require_admin_owner
  before_action :check_totp_disabled, only: [:new, :create]
  before_action :check_totp_enabled, only: [:confirm_disable, :disable]

  def new
    current_admin.generate_otp_secret_if_missing!
    @page_subtitle = t(".page_title")
  end

  def create
    unless current_admin.valid_password?(totp_params[:password])
      flash[:error] = t("devise.failure.admin.invalid")
      return redirect_to new_admin_totp_path
    end

    if current_admin.validate_and_consume_otp!(totp_params[:otp_attempt])
      current_admin.enable_totp!

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

  def disable
    unless current_admin.valid_password?(totp_params[:password])
      flash[:error] = t("devise.failure.admin.invalid")
      return redirect_to confirm_disable_admin_totp_path
    end

    if current_admin.disable_otp!
      flash[:notice] = t(".success")
    else
      flash[:error] = t(".failure")
    end

    redirect_to admin_preferences_path
  end

  private

  def require_admin_owner
    return if params[:admin_id] == current_admin.login

    flash[:error] = t("admin.totp.access.permission_denied_generic")
    redirect_to root_path
  end

  def check_totp_enabled
    return if current_admin.otp_required_for_login

    flash[:error] = t("admin.totp.already_disabled")
    redirect_to admin_preferences_path
  end

  def check_totp_disabled
    return unless current_admin.otp_required_for_login

    flash[:error] = t("admin.totp.already_enabled")
    redirect_to admins_path
  end

  def totp_params
    params.require(:admin).permit(:otp_attempt, :password)
  end
end
