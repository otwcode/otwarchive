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
    else
      @admin_note = params[:admin_note]
      @user = User.find_by_login(params[:user_login])
      submitted_kin_user = User.find_by_login(params[:next_of_kin_name])

      # there is a next of kin username, but no email
      if params[:next_of_kin_name].present? && params[:next_of_kin_email].blank?
        flash[:error] = ts('Fannish next of kin email is missing.')
        redirect_to request.referer || root_path

      # there is a next of kin email, but no username
      elsif params[:next_of_kin_name].blank? && params[:next_of_kin_email].present?
        flash[:error] = ts('Fannish next of kin user is missing.')
        redirect_to request.referer || root_path

      # there is a next of kin username, but it is not a valid user
      elsif params[:next_of_kin_name].present? && submitted_kin_user.nil?
        flash[:error] = ts('Fannish next of kin user is invalid.')
        redirect_to request.referer || root_path

      # there is an admin action selected, but no note entered
      elsif params[:admin_action].present? && @admin_note.blank?
        flash[:error] = ts('You must include notes in order to perform this action.')
        redirect_to request.referer || root_path

      # there is no length entered for the suspension
      elsif params[:admin_action] == 'suspend' && params[:suspend_days].blank?
        flash[:error] = ts('Please enter the number of days for which the user should be suspended.')
        redirect_to request.referer || root_path

      # we made it through without any errors, so let's do some stuff
      else
        success_message = []

        # find or create a fannish next of kin if the fields are filled in
        if params[:next_of_kin_name].present? && params[:next_of_kin_email].present? && @user.fannish_next_of_kin.nil?
          @user.fannish_next_of_kin = FannishNextOfKin.new(user_id: params[:user_login],
                                                           kin_id: submitted_kin_user.id,
                                                           kin_email: params[:next_of_kin_email])
          success_message << ts('Fannish next of kin added.')
        end

        # update the next of kin user if the field is present and changed
        if params[:next_of_kin_name].present? && !(submitted_kin_user.id == @user.fannish_next_of_kin.kin_id)
          @user.fannish_next_of_kin.kin_id = submitted_kin_user.id
          @user.fannish_next_of_kin.save
          success_message << ts('Fannish next of kin user updated.')
        end

        # update the next of kin email is the field is present and changed
        if params[:next_of_kin_email].present? && !(params[:next_of_kin_email] == @user.fannish_next_of_kin.kin_email)
          @user.fannish_next_of_kin.kin_email = params[:next_of_kin_email]
          @user.fannish_next_of_kin.save
          success_message << ts('Fannish next of kin email updated.')
        end

        # delete the next of kin if the fields are blank and changed
        if params[:next_of_kin_user].blank? && params[:next_of_kin_email].blank? && @user.fannish_next_of_kin
          @user.fannish_next_of_kin.destroy
          success_message << ts('Fannish next of kin removed.')
        end

        # create warning
        if params[:admin_action] == 'warn'
          @user.create_log_item(action: ArchiveConfig.ACTION_WARN, note: @admin_note, admin_id: current_admin.id)
          success_message << ts('Warning was recorded.')
        end

        # create suspension
        if params[:admin_action] == 'suspend'
          @user.suspended = true
          @suspension_days = params[:suspend_days].to_i
          @user.suspended_until = @suspension_days.days.from_now
          @user.create_log_item(action: ArchiveConfig.ACTION_SUSPEND, note: @admin_note, admin_id: current_admin.id, enddate: @user.suspended_until)
          success_message << ts('User has been temporarily suspended.')
        end

        # create ban
        if params[:admin_action] == 'ban'
          @user.banned = true
          @user.create_log_item(action: ArchiveConfig.ACTION_BAN, note: @admin_note, admin_id: current_admin.id)
          success_message << ts('User has been permanently suspended.')
        end

        # unsuspended suspended user
        if params[:admin_action] == 'unsuspend' && @user.suspended?
          @user.suspended = false
          @user.suspended_until = nil
          if !@user.suspended && @user.suspended_until.blank?
            @user.create_log_item(action: ArchiveConfig.ACTION_UNSUSPEND, note: @admin_note, admin_id: current_admin.id)
            success_message << ts('Suspension has been lifted.')
          end
        end

        # unban banned user
        if params[:admin_action] == 'unban' && @user.banned?
          @user.banned = false
          if !@user.banned?
            @user.create_log_item(action: ArchiveConfig.ACTION_UNSUSPEND, note: @admin_note, admin_id: current_admin.id)
            success_message << ts('Suspension has been lifted.')
          end
        end

        @user.save
        flash[:notice] = success_message
        redirect_to request.referer || root_path

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

