class UserSessionsController < ApplicationController

  # I hope this isn't catching unwanted exceptions; it's hard to locate
  # where exactly the exception is thrown in case of no cookies. --rebecca
  rescue_from ActionController::InvalidAuthenticityToken, :with => :show_auth_error

  layout "session"
  before_filter :admin_logout_required
  skip_before_filter :store_location


  def show_auth_error
    redirect_to "/auth_error.html"
  end

  def new
  end

  def create
    if params[:user_session]
      @user_session = UserSession.new(params[:user_session])
      if @user_session.save
        flash[:notice] = ts("Successfully logged in.")
        @current_user = @user_session.record
        redirect_back_or_default(@current_user)
      else
        if params[:user_session][:login] && user = User.find_by_login(params[:user_session][:login])
          # we have a user
          if user.recently_reset? && params[:user_session][:password] == user.activation_code
            if user.updated_at > 1.week.ago
              # we sent out a generated password and they're using it
              # log them in
              @current_user = UserSession.create(user, params[:remember_me]).record
              # and tell them to change their password
              redirect_to change_password_user_path(@current_user) and return
            else
              message = ts("The password you entered has expired. Please click the 'Reset password' link below.")
            end
          elsif user.active?
            if @user_session.being_brute_force_protected? 
           
              message = ts("Your account has been locked for 5 minutes due to too many failed login attempts.")
            else
              message = ts("The password or user name you entered doesn't match our records. Please try again or click the 'forgot password' link below.")
            end
          else
            message = ts("You'll need to activate your account before you can log in. Please check your email or contact support.")
          end
        else
          message = ts("The password or user name you entered doesn't match our records. Please try again or click the 'forgot password' link below.")
        end
        flash.now[:error] = message
        @user_session = UserSession.new(params[:user_session])
        render :action => 'new'
      end
    end
  end

  def destroy
    @user_session = UserSession.find
    if @user_session
      @user_session.destroy
      flash[:notice] = ts("Successfully logged out.")
    end
    redirect_back_or_default root_url
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

end
