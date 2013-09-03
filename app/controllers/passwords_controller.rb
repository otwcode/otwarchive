# Use for resetting lost passwords
class PasswordsController < ApplicationController
  skip_before_filter :store_location
  layout "session"

  def new
  end

  def create
    @user = User.find_by_login(params[:login]) || User.find_by_email(params[:login])
    if @user.nil?
      flash[:notice] = ts("We couldn't find an account with that email address or username. Please try again?")
      render :action => "new"
    elsif !@user.active?
      flash.now[:error] = ts("Your account has not been activated. Please check your email (including your spam folder) for the activation link or <a href=\"#{new_feedback_report_url}\">contact Support</a>.".html_safe)
      render :action => "new"
    else
      @user.reset_user_password
      @user_session = UserSession.find
      if @user_session
        @user_session.destroy
      end
      flash[:notice] = t('check_email', :default => 'Check your email for your generated password.')
      redirect_to login_path
    end
  end

end
