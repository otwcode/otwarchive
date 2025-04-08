class AdminsController < Admin::BaseController
  def index
  end

  def preferences
    @totp_enabled = current_admin.otp_required_for_login

    render "admin/preferences/show"
  end

  def totp_setup
    if current_admin.otp_required_for_login
      flash[:alert] = t(".already_enabled")
      return redirect_to admins_path
    end

    current_admin.generate_two_factor_secret_if_missing!

    render "admin/preferences/totp_setup"
  end

  def totp_setup_form
    unless current_admin.valid_password?(enable_2fa_params[:password])
      flash[:alert] = t("devise.failure.admin.invalid")
      return redirect_to totp_setup_admin_path
    end

    if current_admin.validate_and_consume_otp!(enable_2fa_params[:otp_attempt])
      current_admin.enable_two_factor!

      flash[:notice] = t(".success")
      redirect_to totp_setup_backup_codes_admin_path
    else
      flash[:alert] = t(".incorrect_code")
      redirect_to totp_setup_admin_path
    end
  end

  def totp_setup_backup_codes
    unless current_admin.otp_required_for_login
      flash[:alert] = t(".not_enabled")
      return redirect_to totp_setup_admin_path
    end

    if current_admin.two_factor_backup_codes_generated?
      flash[:alert] = t(".already_seen")
      return redirect_to admins_path
    end

    @backup_codes = current_admin.generate_otp_backup_codes!
    current_admin.save!

    render "admin/preferences/totp_setup_backup_codes"
  end

  def totp_disable
    if current_admin.disable_two_factor!
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".failure")
    end

    redirect_to preferences_admin_path
  end

  private

  def enable_2fa_params
    params.permit(:otp_attempt, :password)
  end
end
