# frozen_string_literal: true

# Use for resetting lost passwords
class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :store_location
  layout "session"

  def create
    user = User.find_for_authentication(resource_params.permit(:login))

    if user&.protected_user
      flash[:error] = t(".reset_blocked", contact_abuse_link: view_context.link_to(t(".contact_abuse"), new_abuse_report_path)).html_safe
      redirect_to root_path and return
    elsif user&.password_resets_limit_reached?
      available_time = ApplicationController.helpers.time_in_zone(
        user.password_resets_available_time, nil, user)

      flash[:error] = t(".reset_cooldown", reset_available_time: available_time).html_safe
      redirect_to root_path and return
    end

    super do |user|
      if user.nil? || user.new_record?
        flash.now[:notice] = ts("We couldn't find an account with that email address or username. Please try again?")
      else
        user.update_password_resets_requested
        user.save
      end
    end
  end
end
