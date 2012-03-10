class Admin::AdminUsersController < ApplicationController

  before_filter :admin_only

  def index
    @roles = Role.assignable.uniq
    @role_values = @roles.map{ |role| [role.name.humanize.titlecase, role.name] }
    @role = Role.find_by_name(params[:role]) if params[:role]
    @users = User.search_by_role(@role, params[:query], :inactive => params[:inactive], :page => params[:page])
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

  # POST admin/users/update_user
  def update_user
    if params[:id]
      @user = User.find_by_login(params[:id])
      if @user.admin_update(params[:user])
        flash[:notice] = ts('User was successfully updated.')
        redirect_to(request.env["HTTP_REFERER"] || root_path)
      else
        flash[:error] = ts('There was an error updating user %{name}', :name => params[:id])
        redirect_to(request.env["HTTP_REFERER"] || root_path)
      end
    elsif params[:admin_action]
      @user = User.find_by_login(params[:user_login])
      @admin_note = params[:admin_note]
      if @admin_note.blank?
        flash[:error] = ts("You must include notes in order to perform this action")
        redirect_to(request.env["HTTP_REFERER"] || root_path)
      else
        if params[:admin_action] == 'warn'
          @user.create_log_item( options = {:action => ArchiveConfig.ACTION_WARN, :note => @admin_note, :admin_id => current_admin.id})
          flash[:notice] = ts("Warning was recorded")
          redirect_to(request.env["HTTP_REFERER"] || root_path)
        elsif params[:admin_action] == 'suspend'
          if params[:suspend_days].blank?
            flash[:error] = ts("Please enter the number of days for which the user should be suspended.")
            redirect_to(request.env["HTTP_REFERER"] || root_path)
          else
            @user.suspended = true
            @suspension_days = params[:suspend_days].to_i
            @user.suspended_until = @suspension_days.days.from_now
            if @user.save && @user.suspended? && !@user.suspended_until.blank?
              @user.create_log_item( options = {:action => ArchiveConfig.ACTION_SUSPEND, :note => @admin_note, :admin_id => current_admin.id, :enddate => @user.suspended_until})
              flash[:notice] = ts("User has been temporarily suspended")
              redirect_to(request.env["HTTP_REFERER"] || root_path)
            else
              flash[:error] = ts("User could not be suspended")
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
    @roles = Role.assignable.uniq
  end

  def send_notification
    if !params[:notify_all].blank?
      if params[:notify_all].include?("0")
        # exclude users who've opted out of admin emails, if the message is one to all users
        @users = User.joins(:preference).where("preferences.admin_emails_off = 0")
      else
        # do not exclude users if they are part of a targeted group, like translations, wranglers or individually selected users
        # don't call .count on queries obtained with .group! you'll get a hash instead of an integer
        @users = User.select("users.*").joins(:roles).where("roles.name IN (?)", params[:notify_all]).group("users.id")
      end
    elsif params[:user_ids]
      @users = User.find(params[:user_ids])
    end

    if @users.nil? || @users.length == 0
      flash[:error] = ts("Who did you want to notify?")
      redirect_to :action => :notify and return
    end

    unless params[:subject] && !params[:subject].blank?
      flash[:error] = ts("Please enter a subject.")
      redirect_to :action => :notify and return
    else
      @subject = params[:subject]
    end

    # We need to use content because otherwise html will be stripped
    unless params[:content] && !params[:content].blank?
      flash[:error] = ts("What message did you want to send?")
      redirect_to :action => :notify and return
    else
      @message = params[:content]
    end

    @users.each do |user|
      UserMailer.archive_notification(current_admin.login, user.id, @subject, @message).deliver
    end

    AdminMailer.archive_notification(current_admin.login, @users.map(&:id), @subject, @message).deliver

    flash[:notice] = ts("Notification sent to %{count} user(s).", :count => @users.size)
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
    # send synchronously to avoid getting caught in mail queue
    UserMailer.signup_notification(@user.id).deliver! 
    flash[:notice] = t('activation_sent', :default => "Activation email sent")
    redirect_to :action => :show
  end

end

