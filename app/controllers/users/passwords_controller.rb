# frozen_string_literal: true

# Use for resetting lost passwords
class Users::PasswordsController < Devise::PasswordsController
  before_action :admin_logout_required
  layout "session"

  def create
    user = User.find_for_authentication(resource_params.permit(:login))
    if user.nil? || user.new_record?
      flash[:error] = t(".user_not_found")
      redirect_to new_user_password_path and return
    end

    if user.prevent_password_resets?
      flash[:error] = t(".reset_blocked_html", contact_abuse_link: view_context.link_to(t(".contact_abuse"), new_abuse_report_path))
      redirect_to root_path and return
    elsif user.password_resets_limit_reached?
      available_time = ApplicationController.helpers.time_in_zone(
        user.password_resets_available_time, nil, user
      )

      flash[:error] = t(".reset_cooldown_html", reset_available_time: available_time)
      redirect_to root_path and return
    end

    user.update_password_resets_requested
    user.save

    super
  end

  def edit
    # The token is part of the URL so it might be mangled or expired
    # Check its validity before showing the new password form for improved UX by failing early
    # The token is checked for validity again in #update when actually changing the password
    token_from_url = params[:reset_password_token]
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, token_from_url)

    user = User.find_for_authentication(reset_password_token: reset_password_token)

    if user.nil? || user.new_record?
      flash[:error] = t(".invalid_link", count: ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS)
      redirect_to new_user_password_path and return
    end

    super
  end

  protected

  # We need to include information about the user (the remaining reset attempts)
  # in addition to the configured reset cooldown in the success  message.
  # Otherwise, we would just override `devise_i18n_options` instead of this method.
  def successfully_sent?(resource)
    return super if Devise.paranoid
    return unless resource.errors.empty?

    flash[:notice] = t("users.passwords.create.send_instructions",
                       send_times_remaining: t("users.passwords.create.send_times_remaining",
                                               count: resource.password_resets_remaining),
                       send_cooldown_period: t("users.passwords.create.send_cooldown_period",
                                               count: ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS))
  end

  def after_resetting_password_path_for(resource)
    resource.create_log_item(action: ArchiveConfig.ACTION_PASSWORD_RESET)
    super
  end

  def assert_reset_token_passed
    return if params[:reset_password_token].present?

    set_flash_message(:error, :no_token)
    redirect_to new_user_password_path
  end
end
