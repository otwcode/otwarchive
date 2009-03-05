class Admin::AdminUsersController < ApplicationController
  
  before_filter :admin_only

  def index
    if params[:letter] && params[:letter].is_a?(String)
      letter = params[:letter][0,1]
    else
      letter = User::ALPHABET[0]
    end
    @users = User.alphabetical.starting_with(letter)
  end 

  # GET admin/users/1
  # GET admin/users/1.xml
  def show
    @user = User.find_by_login(params[:id])
  end

  # GET admin/users/1/edit
  def edit
    @user = User.find_by_login(params[:id])
    unless @user
      redirect_to :action => "index", :letter => params[:letter]
    end
  end

  # PUT admin/users/1
  # PUT admin/users/1.xml
  def update
    @user = User.find_by_login(params[:user][:login])
    @user.attributes = params[:user]
    if @user.save(false)
      flash[:notice] = 'User was successfully updated.'.t
      redirect_to :action => "index", :letter => params[:letter]
    else
      flash[:error] = 'There was an error updating user '.t + params[:user][:login]
      redirect_to :action => "index", :letter => params[:letter]
    end
  end

  # DELETE admin/users/1
  # DELETE admin/users/1.xml
  def destroy
    @user = User.find_by_login(params[:id])
    @user.destroy
    redirect_to(admin_users_url) 
  end
  
  def notify
    @users = User.alphabetical
  end
  
  def send_notification
    if params[:user_ids]
      @users = User.with_ids(params[:user_ids])
    end

    if @users.blank?
      flash[:error] = "Who did you want to notify?".t
      redirect_to :action => :notify and return
    end
    
    unless params[:subject] && !params[:subject].blank?
      flash[:error] = "Please enter a subject.".t
      redirect_to :action => :notify and return
    else
      @subject = params[:subject]
    end
    
    # We need to use content because otherwise html will be stripped
    unless params[:content] && !params[:content].blank?
      flash[:error] = "What message did you want to send?".t
      redirect_to :action => :notify and return
    else
      @message = params[:content]
    end
    
    @users.each do |user|
      UserMailer.deliver_archive_notification(current_admin.login, user, @subject, @message)
    end
    
    AdminMailer.deliver_archive_notification(current_admin.login, @users, @subject, @message)
    
    flash[:notice] = "Notification sent to #{@users.size} user(s).".t
    redirect_to :action => :notify
  end

end  

