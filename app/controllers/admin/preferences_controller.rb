class Admin::PreferencesController < Admin::BaseController
  before_action :check_ownership
  before_action :check_totp_disabled, only: [:totp_setup, :totp_setup_form]
  before_action :check_totp_enabled, only: [:totp_disable, :totp_disable_form]

  def check_ownership
    admin_only_access_denied unless params[:admin_id] == current_admin.login
  end

  def check_totp_disabled
    return unless current_admin.otp_required_for_login

    flash[:error] = t("admin.preferences.check_totp_disabled.already_enabled")
    redirect_to admins_path
  end

  def check_totp_enabled
    return if current_admin.otp_required_for_login

    flash[:error] = t("admin.preferences.check_totp_enabled.already_disabled")
    redirect_to admins_path
  end

  def show
    @totp_enabled = current_admin.otp_required_for_login
  end

  def totp_setup
    current_admin.generate_otp_secret_if_missing!
  end

  def totp_setup_form
    unless current_admin.valid_password?(enable_2fa_params[:password])
      flash[:error] = t("devise.failure.admin.invalid")
      return redirect_to totp_setup_admin_preferences_path
    end

    if current_admin.validate_and_consume_otp!(enable_2fa_params[:otp_attempt])
      current_admin.enable_otp!

      flash[:notice] = t(".success")
      redirect_to totp_setup_backup_codes_admin_preferences_path
    else
      flash[:error] = t(".incorrect_code")
      redirect_to totp_setup_admin_preferences_path
    end
  end

  def totp_setup_backup_codes
    unless current_admin.otp_required_for_login
      flash[:error] = t(".not_enabled")
      return redirect_to totp_setup_admin_preferences_path
    end

    if current_admin.otp_backup_codes_generated?
      flash[:error] = t(".already_seen")
      return redirect_to admins_path
    end

    @backup_codes = current_admin.generate_otp_backup_codes!
    current_admin.save!
  end

  def totp_disable_form
    unless current_admin.valid_password?(enable_2fa_params[:password])
      flash[:error] = t("devise.failure.admin.invalid")
      return redirect_to totp_disable_admin_preferences_path
    end

    unless current_admin.validate_and_consume_otp!(enable_2fa_params[:otp_attempt])
      flash[:error] = t(".incorrect_code")
      return redirect_to totp_disable_admin_preferences_path
    end

    if current_admin.disable_otp!
      flash[:notice] = t(".success")
    else
      flash[:error] = t(".failure")
    end

    redirect_to admin_preferences_path
  end

  private

  def enable_2fa_params
    params.require(:admin).permit(:otp_attempt, :password)
  end
end
