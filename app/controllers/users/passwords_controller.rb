# frozen_string_literal: true

# Use for resetting lost passwords
class Users::PasswordsController < Devise::PasswordsController
  before_action :admin_logout_required
  layout "session"

  def new
    @page_subtitle = t(".page_title")
    
    super
  end

  def create
    user = User.find_or_initialize_with_errors([:email], resource_params, :not_found)

    unless params[:user][:email].to_s.match?(EmailFormatValidator.email_regex)
      flash[:error] = t(".invalid_email")
      redirect_to new_user_password_path and return
    end

    if user.nil? || user.new_record? || user.prevent_password_resets? || user.password_resets_limit_reached?
      # Fake success message
      flash[:notice] = t("devise.passwords.user.send_instructions")
      redirect_to new_user_password_path and return
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

    @page_subtitle = t(".page_title")
    super
  end

  protected

  def after_sending_reset_password_instructions_path_for(*)
    new_user_password_path
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
