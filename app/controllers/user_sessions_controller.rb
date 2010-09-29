class UserSessionsController < ApplicationController

  layout "session"
  before_filter :admin_logout_required
  
  
  def new  
    @user_session = UserSession.new  
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])  
    if @user_session.save  
      flash[:notice] = "Successfully logged in."  
      redirect_to :back || current_user  
    else
      # we don't want to highlight the specific erroring fields, just
      # give a nice clean error message at the top of the page.
      if params[:user_session][:login] && user = User.find_by_login(params[:user_session][:login])
        # we have a user 
        if user.active? 
          message = t('wrong_password', :default => "The password you entered doesn't match our records. Please try again or click the 'forgot password' link below.")
        else
          message = t('not_activated', :default => "You'll need to activate your account before you can log in. Please check your email or contact an admin.")
        end
      else 
        message = t('wrong_name', :default => "We couldn't find that name in our database. Please try again.")
      end      
      flash.now[:error] = message
      @user_session = UserSession.new(params[:user_session]) 
      render :action => 'new'
    end
  end
  
  def destroy
    @user_session = UserSession.find  
    @user_session.destroy  
    flash[:notice] = "Successfully logged out."  
    redirect_to root_url
  end
  
end
