class UserSessionsController < ApplicationController

  layout "session"
  before_action :admin_logout_required
  skip_before_action :store_location

  def new
  end

  def create
    if params[:user_session]
      # Need to convert params back to a hash for Authlogic bug
      @user_session = UserSession.new(user_session_params.to_hash)

      if @user_session.save
        flash[:notice] = ts("Successfully logged in.")
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
