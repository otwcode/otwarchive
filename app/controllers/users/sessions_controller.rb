class Users::SessionsController < Devise::SessionsController
  layout "session"
  before_action :admin_logout_required

  prepend_before_action :authenticate_with_totp_two_factor, 
                        if: -> { action_name == "create" && totp_two_factor_enabled? }
  
  protect_from_forgery with: :exception, prepend: true, except: :destroy

  # POST /users/login
  def create
    super do |resource|
      unless resource.remember_me
        message = ts(" <strong>You'll stay logged in for %{number} weeks even if you close your browser, so make sure to log out if you're using a public or shared computer.</strong>", number: ArchiveConfig.DEFAULT_SESSION_LENGTH_IN_WEEKS)
      end
      flash[:notice] += message unless message.nil?
      flash[:notice] = flash[:notice].html_safe
    end
  end

  # GET /users/logout
  def confirm_logout
    # If the user is already logged out, we just redirect to the front page.
    redirect_to root_path unless user_signed_in?
  end

  include PathCleaner
  # DELETE /users/logout
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out

    redirect_to relative_path(params[:return_to]) || root_path
  end

  # Two-Factor Authentication
  def authenticate_with_totp_two_factor
    user = self.resource = find_user

    if params[:totp_attempt].present? && session[:otp_user_id]
      authenticate_user_with_otp_two_factor(user)
    elsif user&.valid_password?(user_params[:password])
      prompt_for_otp_two_factor(user)
    end
  end

  private

  def valid_totp_attempt?(user)
    user.validate_and_consume_otp!(params[:totp_attempt]) ||
      user.invalidate_otp_backup_code!(params[:totp_attempt])
  end

  def prompt_for_otp_two_factor(user)
    @user = user

    session[:otp_user_id] = user.id
    
    session[:pwned] = user.respond_to?(:password_pwned?) && user.password_pwned?(user_params[:password]) if params[:user] && params[:user][:password]

    render "users/sessions/totp"
  end

  def authenticate_user_with_otp_two_factor(user)
    if valid_totp_attempt?(user)
      pwned = session[:pwned]
      # Remove any lingering user data from login
      session.delete(:otp_user_id)
      session.delete(:pwned)

      user.save!

      flash[:notice] = t("devise.sessions.signed_in")
      sign_in(user, event: :authentication)

      # Set the user_credentials flag cookie
      # because this login flow bypasses ensure_user_credentials#ensure_user_credentials
      cookies[:user_credentials] = { value: 1, expires: 1.year.from_now } unless cookies[:user_credentials]

      if pwned
        # Set the pwned flash notice
        # because this login flow bypasses ApplicationController#after_sign_in_path_for
        set_flash_message! :alert, :warn_pwned
        redirect_to change_password_user_path(user)
      else
        redirect_to root_path
      end
    else
      flash.now[:error] = t("users.sessions.invalid_totp")
      prompt_for_otp_two_factor(user)
    end
  end

  def user_params
    params.require(:user).permit(:login, :password, :remember_me)
  end

  def find_user
    if session[:otp_user_id]
      User.find(session[:otp_user_id])
    elsif user_params[:login]
      User.find_by(login: user_params[:login])
    end
  end

  def totp_two_factor_enabled?
    find_user&.totp_enabled?
  end
end
