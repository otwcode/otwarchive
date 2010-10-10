class Admin::AdminUsersController < ApplicationController
  
  before_filter :admin_only

  def index
    if params[:role]
      if params[:role] == "0" && params[:query].blank?
        return flash[:error] = "Please enter a name or email address!"
      elsif params[:role] == "0"
        joins = :pseuds
        conditions = ['pseuds.name LIKE ? OR email = ?', "%#{params[:query]}%", params[:query]]
      elsif params[:role] == "1"  
        if !params[:query].blank?      
          joins = :pseuds
          conditions = [('(pseuds.name LIKE ? OR email = ?) AND activated_at IS NULL'), "%#{params[:query]}%", params[:query]]
        else
          conditions = ['activated_at IS NULL']
        end
      else
        if !params[:query].blank?
          joins = [:pseuds, :roles]
          conditions = ['(pseuds.name LIKE ? OR email = ?) AND roles.name = ?', "%#{params[:query]}%", params[:query], params[:role]]
        else
          joins = :roles 
          conditions = ['roles.name = ?', params[:role]]
        end
      end
      @users = User.select('DISTINCT users.*').joins(joins).where(conditions)
    end
  end

  # GET admin/users/1
  # GET admin/users/1.xml
  def show
    @hide_dashboard = true
    @user = User.find_by_login(params[:id])
    unless @user
      redirect_to :action => "index", :query => params[:query], :role => params[:role]
    end    
    @log_items = @user.log_items.sort_by(&:created_at).reverse
  end

  # GET admin/users/1/edit
  def edit
    @user = User.find_by_login(params[:id])
    unless @user
      redirect_to :action => "index", :query => params[:query], :role => params[:role]
    end
  end

  # PUT admin/users/1
  # PUT admin/users/1.xml
  def update
    if params[:user]
      @user = User.find_by_login(params[:user][:login]) 
      #:suspended, :banned, :translation_admin, :tag_wrangler, :archivist, :recently_reset 
      @user.translation_admin = params[:user][:translation_admin] if params[:user][:translation_admin]
      @user.tag_wrangler = params[:user][:tag_wrangler] if params[:user][:tag_wrangler]
      @user.archivist = params[:user][:archivist] if params[:user][:archivist]
      if @user.save(:validate => false)
        flash[:notice] = t('successfully_updated', :default => 'User was successfully updated.')
        redirect_to(request.env["HTTP_REFERER"] || root_path)
      else
        flash[:error] = t('error_updating', :default => 'There was an error updating user %{name}', :name => params[:user][:login])
        redirect_to(request.env["HTTP_REFERER"] || root_path)
      end
    elsif params[:admin_action]
      @user = User.find_by_login(params[:user_login])
      @admin_note = params[:admin_note]
      if @admin_note.blank?
        flash[:error] = t('note_required', :default => "You must include notes in order to perform this action")
        redirect_to(request.env["HTTP_REFERER"] || root_path)
      else
        if params[:admin_action] == 'warn'
          @user.create_log_item( options = {:action => ArchiveConfig.ACTION_WARN, :note => @admin_note, :admin_id => current_admin.id})
          flash[:notice] = t('success_warned', :default => "Warning was recorded") 
          redirect_to(request.env["HTTP_REFERER"] || root_path)
        elsif params[:admin_action] == 'suspend'
          if params[:suspend_days].blank?
            flash[:error] = t('error_date_required', :default => "Please enter the number of days for which the user should be suspended.")
            redirect_to(request.env["HTTP_REFERER"] || root_path)
          else
            @user.suspended = true
            @suspension_days = params[:suspend_days].to_i
            @user.suspended_until = @suspension_days.days.from_now
            if @user.save && @user.suspended? && !@user.suspended_until.blank?
              @user.create_log_item( options = {:action => ArchiveConfig.ACTION_SUSPEND, :note => @admin_note, :admin_id => current_admin.id, :enddate => @user.suspended_until})
              flash[:notice] = t('success_suspended', :default => "User has been temporarily suspended") 
              redirect_to(request.env["HTTP_REFERER"] || root_path)
            else
              flash[:error] = t('error_suspended', :default => "User could not be suspended") 
              redirect_to(request.env["HTTP_REFERER"] || root_path)
            end
          end
        elsif params[:admin_action] == 'ban'
          @user.banned = true
          if @user.save && @user.banned?
            @user.create_log_item( options = {:action => ArchiveConfig.ACTION_BAN, :note => @admin_note, :admin_id => current_admin.id})
            flash[:notice] = t('success_banned', :default => "User has been permanently suspended") 
            redirect_to(request.env["HTTP_REFERER"] || root_path)
          else  
            flash[:error] = t('error_banned', :default => "User could not be permanently suspended") 
            redirect_to(request.env["HTTP_REFERER"] || root_path)
          end
        elsif params[:admin_action] == 'unsuspend'
          if @user.suspended?
            @user.suspended = false
            @user.suspended_until = nil
            if @user.save && !@user.suspended? && @user.suspended_until.blank?
              @user.create_log_item( options = {:action => ArchiveConfig.ACTION_UNSUSPEND, :note => @admin_note, :admin_id => current_admin.id})
              flash[:notice] = t('success_unsuspend', :default => "Suspension has been lifted") 
              redirect_to(request.env["HTTP_REFERER"] || root_path)
            else
              flash[:error] = t('error_unsuspend', :default => "Suspension could not be lifted") 
              redirect_to(request.env["HTTP_REFERER"] || root_path)
            end
          else
            flash[:notice] = t('not_suspended', :default => "User had not been suspended") 
            redirect_to(request.env["HTTP_REFERER"] || root_path)
          end
        elsif params[:admin_action] == 'unban'
          if @user.banned?
            @user.banned = false
            if @user.save && !@user.banned?
              @user.create_log_item( options = {:action => ArchiveConfig.ACTION_UNSUSPEND, :note => @admin_note, :admin_id => current_admin.id})
              flash[:notice] = t('success_unsuspend', :default => "Suspension has been lifted") 
              redirect_to(request.env["HTTP_REFERER"] || root_path)
            else
              flash[:error] = t('error_unsuspend', :default => "Suspension could not be lifted") 
              redirect_to(request.env["HTTP_REFERER"] || root_path)
            end
          else
            flash[:notice] = t('not_banned', :default => "User had not been permanently suspended") 
            redirect_to(request.env["HTTP_REFERER"] || root_path)
          end
        end
      end
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
      letter = '0'
    end
    @all_users = User.alphabetical.starting_with(letter)
  end
  
  def send_notification
    if !params[:notify_all].blank?
      if params[:notify_all].include?("0")
        # exclude users who've opted out of admin emails, if the message is one to all users
        @users = User.all.select {|u| !u.preference.admin_emails_off?}
      else
        # do not exclude users if they are part of a targeted group, like translations, wranglers or individually selected users
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
      UserMailer.archive_notification(current_admin.login, user, @subject, @message).deliver
    end
    
    AdminMailer.archive_notification(current_admin.login, @users, @subject, @message).deliver
    
    flash[:notice] = t('sent', :default => "Notification sent to %{count} user(s).", :count => @users.size)
    redirect_to :action => :notify
  end

  def activate
    @user = User.find_by_login(params[:id])
    @user.activate
    if @user.active?
      @user.create_log_item( options = {:action => ArchiveConfig.ACTION_ACTIVATE, :note => 'Manually Activated', :admin_id => current_admin.id})
      flash[:notice] = t('activated', :default => "User Account Activated") 
      redirect_to :action => :show
    else
      flash[:error] = t('activation_failed', :default => "Attempt to activate account failed.")
      redirect_to :action => :show
    end
  end
  
  def send_activation
    @user = User.find_by_login(params[:id])
    UserMailer.signup_notification(@user).deliver
    flash[:notice] = t('activation_sent', :default => "Activation email sent")
    redirect_to :action => :show
  end

end  

