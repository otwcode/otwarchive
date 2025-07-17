# frozen_string_literal: true

# Use for resetting lost passwords
class Users::PasswordsController < Devise::PasswordsController
  before_action :admin_logout_required
  skip_before_action :store_location
  layout "session"

  def create
    user = User.find_for_authentication(resource_params.permit(:email))

    unless params[:user][:email].to_s.match?(/\A[^@]+@[^@]+\z/)
      flash[:error] = t(".invalid_email")
      redirect_to new_user_password_path and return
    end

    if user.nil? || user.new_record? || user.prevent_password_resets? || user.password_resets_limit_reached?
      # Fake success message
      flash[:notice] = t(".send_instructions")
      redirect_to new_user_session_path and return
    end

    user.update_password_resets_requested
    user.save

    super
  end

  protected

  def after_resetting_password_path_for(resource)
    resource.create_log_item(action: ArchiveConfig.ACTION_PASSWORD_RESET)
    super
  end
end
