# frozen_string_literal: true

class Admin::PasswordsController < Devise::PasswordsController
  before_action :user_logout_required
  before_action :load_totp_admin, only: [:edit, :update]
  before_action :require_valid_totp_attempt, only: :update
  layout "session"

  private

  # Find the admin the reset token belongs to, but only when they have
  # two-step verification enabled and the token can still be used.
  def load_totp_admin
    token = params[:reset_password_token] ||
            resource_params[:reset_password_token]
    return if token.blank?

    admin = Admin.with_reset_password_token(token)
    return unless admin&.reset_password_period_valid? && admin&.totp_enabled?

    @totp_admin = admin
  end

  def require_valid_totp_attempt
    return if @totp_admin.nil? || valid_totp_attempt?(@totp_admin)

    self.resource = resource_class.new
    set_minimum_password_length
    resource.reset_password_token = resource_params[:reset_password_token]

    flash.now[:error] = t("admin.passwords.invalid_totp")
    render :edit
  end

  def valid_totp_attempt?(admin)
    admin.validate_and_consume_otp!(params[:totp_attempt]) ||
      admin.invalidate_otp_backup_code!(params[:totp_attempt])
  end
end
