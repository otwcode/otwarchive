# frozen_string_literal: true

class Admin::PasswordsController < Devise::PasswordsController
  before_action :user_logout_required
  layout "session"

  before_action :check_if_totp_required, only: [:edit]
  before_action :verify_otp_code, only: [:update]

  def check_if_totp_required
    admin = find_admin_by_reset_password_token(params[:reset_password_token])

    return unless admin

    @totp_required = admin.otp_required_for_login
  end

  def verify_otp_code
    admin = find_admin_by_reset_password_token(admin_params[:reset_password_token])

    return unless admin

    return unless admin.otp_required_for_login && !valid_otp_attempt?(admin)

    flash[:error] = t("admin.sessions.invalid_totp")

    redirect_to edit_admin_password_path(reset_password_token: admin_params[:reset_password_token])
  end

  private

  def find_admin_by_reset_password_token(original_token)
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)

    Admin.find_by(reset_password_token: reset_password_token)
  end

  def valid_otp_attempt?(admin)
    admin.validate_and_consume_otp!(admin_params[:otp_attempt]) ||
      admin.invalidate_otp_backup_code!(admin_params[:otp_attempt])
  end
    
  def admin_params
    params.require(:admin).permit(:reset_password_token, :otp_attempt, :password, :password_confirmation)
  end
end
