class Admin::TotpController < Admin::BaseController
  before_action :require_admin_owner
  before_action :check_totp_disabled, only: [:new, :create]
  before_action :check_totp_enabled, only: [:confirm_disable, :disable]

  def new
    current_admin.generate_totp_secret_if_missing!
    @page_subtitle = t(".page_title")
  end

  def create
    unless current_admin.valid_password?(totp_params[:password_check])
      flash[:error] = t(".incorrect_password")
      redirect_to new_admin_totp_path and return
    end

    if current_admin.validate_and_consume_otp!(totp_params[:totp_attempt])
      current_admin.enable_totp!

      flash[:notice] = t(".success")
      redirect_to show_backup_codes_admin_totp_path
    else
      flash[:error] = t(".incorrect_code")
      render action: :new and return
    end
  end

  def show_backup_codes
    unless current_admin.totp_enabled?
      flash[:error] = t(".not_enabled")
      redirect_to new_admin_totp_path and return
    end

    if current_admin.totp_backup_codes_generated?
      flash[:error] = t(".already_seen")
      redirect_to admins_path and return
    end

    @page_subtitle = t(".page_title")
    @backup_codes = current_admin.generate_otp_backup_codes!
    current_admin.save!
  end

  def confirm_disable
    @page_subtitle = t(".page_title")
  end

  def disable
    unless current_admin.valid_password?(totp_params[:password_check])
      flash.now[:error] = t(".incorrect_password")
      render action: :confirm_disable and return
    end

    if current_admin.disable_totp!
      flash[:notice] = t(".success")
    else
      flash[:error] = t(".failure")
    end

    redirect_to admins_path
  end

  private

  def require_admin_owner
    return if params[:admin_id] == current_admin.login

    flash[:error] = t("admin.totp.access.permission_denied_generic")
    redirect_to root_path
  end

  def check_totp_enabled
    return if current_admin.totp_enabled?

    flash[:error] = t("admin.totp.already_disabled")
    redirect_to admins_path
  end

  def check_totp_disabled
    return unless current_admin.totp_enabled?

    flash[:error] = t("admin.totp.already_enabled")
    redirect_to admins_path
  end

  def totp_params
    params.require(:admin).permit(:totp_attempt, :password_check)
  end
end
