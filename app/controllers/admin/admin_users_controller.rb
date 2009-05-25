class Admin::AdminUsersController < ApplicationController
  
  before_filter :admin_only

  def index
    if (params[:role].blank? || params[:role] == "0") && params[:pseud].blank? && params[:email].blank?
      flash[:error] = "Please select at least one parameter for your search!"
      redirect_to :back and return
    elsif !params[:pseud].blank?
      @users = Pseud.find(:all, :conditions => ['name LIKE ?', "%#{params[:pseud]}%"]).collect(&:user).uniq      
    end
    if !params[:email].blank?
      @users = (@users || User.all).select{|u| u.email && u.email.include?(params[:email])}
    end
    if !params[:role].blank? && params[:role] != "0"
      @users = (@users || User.all).select{|u| u.roles.collect(&:name).include?(params[:role])}.uniq
    end
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
      redirect_to :action => "index", :pseud => params[:pseud], :role => params[:role]
    end
  end

  # PUT admin/users/1
  # PUT admin/users/1.xml
  def update
    @user = User.find_by_login(params[:user][:login])
    @user.attributes = params[:user]
    if @user.save(false)
      flash[:notice] = t('successfully_updated', :default => 'User was successfully updated.')
      redirect_to :action => "index", :pseud => params[:pseud], :role => params[:role]
    else
      flash[:error] = t('error_updating', :default => 'There was an error updating user {{name}}', :name => params[:user][:login])
      redirect_to :action => "index", :pseud => params[:pseud], :role => params[:role]
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
    if params[:letter] && params[:letter].is_a?(String)
      letter = params[:letter][0,1]
    else
      letter = User::ALPHABET[0]
    end
    @all_users = User.alphabetical.starting_with(letter)
  end
  
  def send_notification
    if !params[:notify_all].blank?
      if params[:notify_all].include?("0")
        @users = User.all
      else
        @users = []
        params[:notify_all].each do |role_name|
          @users += User.all.select{|u| u.roles.collect(&:name).include?(role_name)}
        end
        @users = @users.uniq
      end
    elsif params[:user_ids]
      @users = User.find(params[:user_ids])
    end
   
    if @users.blank?
      flash[:error] = t('no_user', :default => "Who did you want to notify?")
      redirect_to :action => :notify and return
    end
    
    unless params[:subject] && !params[:subject].blank?
      flash[:error] = t('no_subject', :default => "Please enter a subject.")
      redirect_to :action => :notify and return
    else
      @subject = params[:subject]
    end
    
    # We need to use content because otherwise html will be stripped
    unless params[:content] && !params[:content].blank?
      flash[:error] = t('no_message', :default => "What message did you want to send?")
      redirect_to :action => :notify and return
    else
      @message = params[:content]
    end
    
    @users.each do |user|
      UserMailer.deliver_archive_notification(current_admin.login, user, @subject, @message)
    end
    
    AdminMailer.deliver_archive_notification(current_admin.login, @users, @subject, @message)
    
    flash[:notice] = t('sent', :default => "Notification sent to {{count}} user(s).", :count => @users.size)
    redirect_to :action => :notify
  end

end  

