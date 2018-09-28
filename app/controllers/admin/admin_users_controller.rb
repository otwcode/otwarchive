class Admin::AdminUsersController < ApplicationController
  include ExportsHelper

  before_action :admin_only

  def index
    @role_values = @roles.map{ |role| [role.name.humanize.titlecase, role.name] }
    @role = Role.find_by(name: params[:role]) if params[:role]
    @users = User.search_by_role(@role, params[:query], inactive: params[:inactive], page: params[:page])
  end

  def bulk_search
    @emails = params[:emails].split if params[:emails]
    unless @emails.nil? || @emails.blank?
      all_users, @not_found = User.search_multiple_by_email(@emails)
      @users = all_users.paginate(page: params[:page] || 1)
      if params[:download_button]
        header = [%w(Email Username)]
        found = all_users.map { |u| [u.email, u.login] }
        not_found = @not_found.map { |email| [email, ""] }
        send_csv_data(header + found + not_found, "bulk_user_search_#{Time.now.strftime("%Y-%m-%d-%H%M")}.csv")
        flash.now[:notice] = ts("Downloaded CSV")
      end
    end
  end

  before_action :set_roles, only: [:index, :bulk_search]
  def set_roles
    @roles = Role.assignable.distinct
  end

  # GET admin/users/1
  # GET admin/users/1.xml
  def show
    @hide_dashboard = true
    @user = User.find_by(login: params[:id])
    unless @user
      redirect_to action: "index", query: params[:query], role: params[:role] and return
    end
    @log_items = @user.log_items.sort_by(&:created_at).reverse
  end

  # GET admin/users/1/edit
  def edit
    @user = User.find_by(login: params[:id])
    unless @user
      redirect_to action: "index", query: params[:query], role: params[:role]
    end
  end

  # POST admin/users/update_user
  def update_user
    if params[:id]
      @user = User.find_by(login: params[:id])
      if @user.admin_update(params[:user])
        flash[:notice] = ts("User was successfully updated.")
        redirect_to(request.env["HTTP_REFERER"] || root_path)
      else
        flash[:error] = ts("There was an error updating user %{name}", name: params[:id])
        redirect_to(request.env["HTTP_REFERER"] || root_path)
      end
    else
      @admin_note = params[:admin_note]
      # default note for spammers
      @admin_note = (@admin_note.blank? ? "Banned for spam" : @admin_note) if params[:admin_action] == "spamban"

      @user = User.find_by(login: params[:user_login])
      submitted_kin_user = User.find_by(login: params[:next_of_kin_name])

      # there is a next of kin username, but no email
      if params[:next_of_kin_name].present? && params[:next_of_kin_email].blank?
        flash[:error] = ts("Fannish next of kin email is missing.")
        redirect_to request.referer || root_path

      # there is a next of kin email, but no username
      elsif params[:next_of_kin_name].blank? && params[:next_of_kin_email].present?
        flash[:error] = ts("Fannish next of kin user is missing.")
        redirect_to request.referer || root_path

      # there is a next of kin username, but it is not a valid user
      elsif params[:next_of_kin_name].present? && submitted_kin_user.nil?
        flash[:error] = ts("Fannish next of kin user is invalid.")
        redirect_to request.referer || root_path

      # there is an admin action selected, but no note entered
      elsif params[:admin_action].present? && @admin_note.blank?
        flash[:error] = ts("You must include notes in order to perform this action.")
        redirect_to request.referer || root_path

      # there is no length entered for the suspension
      elsif params[:admin_action] == "suspend" && params[:suspend_days].blank?
        flash[:error] = ts("Please enter the number of days for which the user should be suspended.")
        redirect_to request.referer || root_path

      # we made it through without any errors, so let's do some stuff
      else
        success_message = []

        # find or create a fannish next of kin if the fields are filled in
        if params[:next_of_kin_name].present? && params[:next_of_kin_email].present? && @user.fannish_next_of_kin.nil?
          @user.fannish_next_of_kin = FannishNextOfKin.new(user_id: params[:user_login],
                                                           kin_id: submitted_kin_user.id,
                                                           kin_email: params[:next_of_kin_email])
          success_message << ts("Fannish next of kin added.")
        end

        # update the next of kin user if the field is present and changed
        if params[:next_of_kin_name].present? && !(submitted_kin_user.id == @user.fannish_next_of_kin.kin_id)
          @user.fannish_next_of_kin.kin_id = submitted_kin_user.id
          @user.fannish_next_of_kin.save
          success_message << ts("Fannish next of kin user updated.")
        end

        # update the next of kin email is the field is present and changed
        if params[:next_of_kin_email].present? && !(params[:next_of_kin_email] == @user.fannish_next_of_kin.kin_email)
          @user.fannish_next_of_kin.kin_email = params[:next_of_kin_email]
          @user.fannish_next_of_kin.save
          success_message << ts("Fannish next of kin email updated.")
        end

        # delete the next of kin if the fields are blank and changed
        if params[:next_of_kin_user].blank? && params[:next_of_kin_email].blank? && @user.fannish_next_of_kin
          @user.fannish_next_of_kin.destroy
          success_message << ts("Fannish next of kin removed.")
        end

        # create warning
        if params[:admin_action] == "warn"
          @user.create_log_item(action: ArchiveConfig.ACTION_WARN, note: @admin_note, admin_id: current_admin.id)
          success_message << ts("Warning was recorded.")
        end

        # create suspension
        if params[:admin_action] == "suspend"
          @user.suspended = true
          @suspension_days = params[:suspend_days].to_i
          @user.suspended_until = @suspension_days.days.from_now
          @user.create_log_item(action: ArchiveConfig.ACTION_SUSPEND, note: @admin_note, admin_id: current_admin.id, enddate: @user.suspended_until)
          success_message << ts("User has been temporarily suspended.")
        end

        # create ban
        if params[:admin_action] == "ban" || params[:admin_action] == "spamban"
          @user.banned = true
          @user.create_log_item(action: ArchiveConfig.ACTION_BAN, note: @admin_note, admin_id: current_admin.id)
          success_message << ts("User has been permanently suspended.")
        end

        # unsuspended suspended user
        if params[:admin_action] == "unsuspend" && @user.suspended?
          @user.suspended = false
          @user.suspended_until = nil
          if !@user.suspended && @user.suspended_until.blank?
            @user.create_log_item(action: ArchiveConfig.ACTION_UNSUSPEND, note: @admin_note, admin_id: current_admin.id)
            success_message << ts("Suspension has been lifted.")
          end
        end

        # unban banned user
        if params[:admin_action] == "unban" && @user.banned?
          @user.banned = false
          if !@user.banned?
            @user.create_log_item(action: ArchiveConfig.ACTION_UNSUSPEND, note: @admin_note, admin_id: current_admin.id)
            success_message << ts("Suspension has been lifted.")
          end
        end

        @user.save
        flash[:notice] = success_message
        if params[:admin_action] == "spamban"
          redirect_to confirm_delete_user_creations_admin_user_path(@user)
        else
          redirect_to request.referer || root_path
        end

      end
    end
  end

  before_action :user_is_banned, only: [:confirm_delete_user_creations, :destroy_user_creations]
  def user_is_banned
    @user = User.find_by(login: params[:id])
    unless @user && @user.banned?
      flash[:error] = ts("That user is not banned!")
      redirect_to admin_users_path and return
    end
  end

  def confirm_delete_user_creations
    @works = @user.works.paginate(page: params[:works_page])
    @comments = @user.comments.paginate(page: params[:comments_page])
    @bookmarks = @user.bookmarks
    @collections = @user.collections
    @series = @user.series
  end

  def destroy_user_creations
    creations = @user.works + @user.bookmarks + @user.collections + @user.comments
    creations.each do |creation|
      AdminActivity.log_action(current_admin, creation, action: "destroy spam", summary: creation.inspect)
      creation.mark_as_spam! if creation.respond_to?(:mark_as_spam!)
      creation.destroy
    end
    flash[:notice] = ts("All creations by user %{login} have been deleted.", login: @user.login)
    redirect_to(admin_users_path)
  end

  def troubleshoot
    @user = User.find_by(login: params[:id])
    @user.fix_user_subscriptions
    @user.set_user_work_dates
    @user.reindex_user_creations
    @user.update_works_index_timestamp!
    @user.create_log_item(options = { action: ArchiveConfig.ACTION_TROUBLESHOOT, admin_id: current_admin.id })
    flash[:notice] = ts("User account troubleshooting complete.")
    redirect_to(request.env["HTTP_REFERER"] || root_path) && return
  end

  def activate
    @user = User.find_by(login: params[:id])
    @user.activate
    if @user.active?
      @user.create_log_item( options = { action: ArchiveConfig.ACTION_ACTIVATE, note: "Manually Activated", admin_id: current_admin.id })
      flash[:notice] = ts("User Account Activated")
      redirect_to action: :show
    else
      flash[:error] = ts("Attempt to activate account failed.")
      redirect_to action: :show
    end
  end

  def send_activation
    @user = User.find_by(login: params[:id])
    # send synchronously to avoid getting caught in mail queue
    UserMailer.signup_notification(@user.id).deliver!
    flash[:notice] = ts("Activation email sent")
    redirect_to action: :show
  end

end
