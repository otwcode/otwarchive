# frozen_string_literal: true

# Use for resetting lost passwords
class Users::PasswordsController < Devise::PasswordsController
  before_action :admin_logout_required
  skip_before_action :store_location
  layout "session"

  def new
    @page_title = t(".browser_title")
    
    super
  end

  def create
    user = User.find_or_initialize_with_errors([:email], resource_params, :not_found)

    email_regex ||= begin
      email_name_regex = '[A-Z0-9_\.&%\+\-\']+'
      domain_head_regex = "(?:[A-Z0-9\-]+\.)+"
      domain_tld_regex = "(?:[A-Z]{2,25})"
      /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
    end

    unless params[:user][:email].to_s.match?(email_regex)
      flash[:error] = t(".invalid_email")
      redirect_to new_user_password_path and return
    end

    if user.nil? || user.new_record? || user.prevent_password_resets? || user.password_resets_limit_reached?
      # Fake success message
      flash[:notice] = t("devise.passwords.send_instructions")
      redirect_to new_user_password_path and return
    end

    user.update_password_resets_requested
    user.save

    super
  end

  def after_sending_reset_password_instructions_path_for(*)
    new_user_password_path
  end

  protected

  def after_resetting_password_path_for(resource)
    resource.create_log_item(action: ArchiveConfig.ACTION_PASSWORD_RESET)
    super
  end
end
