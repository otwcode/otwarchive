class UserSessionsController < ApplicationController

  layout "session"
  before_action :admin_logout_required
  skip_before_action :store_location

  def new
  end

  def create
    if params[:user_session]
      # We currently remember users for 2 weeks even if they do not check
      # "Remember me" when logging in. To make it last longer for users who
      # do check "Remember me," we have to set a different value before we
      # create the session.
      if user_session_params[:remember_me] == "1"
        UserSession.remember_me_for = ArchiveConfig.REMEMBERED_SESSION_LENGTH_IN_MONTHS.months
      end
      # Need to convert params back to a hash for Authlogic bug
      @user_session = UserSession.new(user_session_params.to_hash)

      if @user_session.save
        flash[:notice] = ts("Successfully logged in.").html_safe
        # Remembering users who don't check "Remember me" is non-standard
        # behavior, so we want to make sure they are aware of it
        unless user_session_params[:remember_me] == "1"
          flash[:notice] += ts(" <strong>You'll stay logged in for %{number} weeks even if you close your browser, so make sure to log out if you're using a public or shared computer.</strong>", number: ArchiveConfig.DEFAULT_SESSION_LENGTH_IN_WEEKS).html_safe
        end
        @current_user = @user_session.record
        redirect_back_or_default(@current_user)
      else
        if params[:user_session][:login] && user = User.find_by(login: params[:user_session][:login])
          # we have a user
          if user.recently_reset? && params[:user_session][:password] == user.activation_code
            if user.updated_at > 1.week.ago
              # we sent out a generated password and they're using it
              # log them in
              @current_user = UserSession.create(user, user_session_params[:remember_me]).record
              # flash a notice telling user to change password, and redirect them
              # to the correct form
              flash[:notice] = ts('You used a temporary password to log in.
                                   Please change it now as it will expire in a
                                   week.')
              redirect_to change_password_user_path(@current_user) and return
            else
              message = ts("The password you entered has expired. Please click the 'Reset password' link below.")
            end
          elsif user.active?
            if @user_session.being_brute_force_protected?
              message = ts("Your account has been locked for 5 minutes due to too many failed login attempts.")
            else
              message = ts("The password or user name you entered doesn't match our records. Please try again or <a href=\"#{new_password_path}\">reset your password</a>. If you still can't log in, please visit <a href=\"#{admin_posts_path + '/1277'}\">Problems When Logging In</a> for help.".html_safe)
            end
          else
            message = ts("You'll need to activate your account before you can log in. Please check your email or contact support.")
          end
        else
          message = ts("The password or user name you entered doesn't match our records. Please try again or <a href=\"#{new_password_path}\">reset your password</a>. If you still can't log in, please visit <a href=\"#{admin_posts_path + '/1277'}\">Problems When Logging In</a> for help.".html_safe)
        end
        flash.now[:error] = message
        @user_session = UserSession.new(user_session_params)
        render action: 'new'
      end
      # Set the session value back to 2 weeks so the next session
      # doesn't also get remembered for 3 months
      UserSession.remember_me_for = ArchiveConfig.DEFAULT_SESSION_LENGTH_IN_WEEKS.weeks
    end
  end

  def destroy
    @user_session = UserSession.find
    if @user_session
      @user_session.destroy
      flash[:notice] = ts("Successfully logged out.")
    end
    redirect_back_or_default root_path
  end

  def passwd_small
    respond_to do |format|
      format.html { redirect_to login_path }
      format.js
    end
  end

  def passwd
    respond_to do |format|
      format.html { redirect_to login_path }
      format.js
    end
  end

  private

  def user_session_params
    params.require(:user_session).permit(
      :login,
      :password,
      :remember_me
    )
  end

end
