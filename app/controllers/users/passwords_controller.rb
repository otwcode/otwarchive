# frozen_string_literal: true

# Use for resetting lost passwords
class Users::PasswordsController < Devise::PasswordsController
  before_action :admin_logout_required
  skip_before_action :store_location
  layout "session"

  def create
    user = User.find_for_authentication(resource_params.permit(:login))

    if user&.prevent_password_resets?
      flash[:error] = t(".reset_blocked", contact_abuse_link: view_context.link_to(t(".contact_abuse"), new_abuse_report_path)).html_safe
      redirect_to root_path and return
    elsif user&.password_resets_limit_reached?
      available_time = ApplicationController.helpers.time_in_zone(
        user.password_resets_available_time, nil, user
      )

      flash[:error] = t(".reset_cooldown", reset_available_time: available_time).html_safe
      redirect_to root_path and return
    end

    if user.present? && !user.new_record?
      user.update_password_resets_requested
      user.save
    end

    super do |target_user|
      if target_user.nil? || target_user.new_record?
        flash.now[:notice] = ts(
          "We couldn't find an account with that email address or username. Please try again?"
        )
      end
    end
  end

  protected

  # We need to include information about the user (the remaining reset attempts)
  # in addition to the Archive's configured reset cooldown in the success
  # message. Otherwise, we would just override `devise_i18n_options` instead of
  # this method.
  def successfully_sent?(resource)
    return super if Devise.paranoid
    return unless resource.errors.empty?

    flash[:notice] = t(".create.send_instructions",
                       send_times_remaining: t(".create.send_times_remaining",
                                               count: resource.password_resets_remaining),
                       send_cooldown_period: t(".create.send_cooldown_period",
                                               count: ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS))
  end
end
