class Admin::AdminUsersController < Admin::BaseController
  include ExportsHelper

  before_action :set_roles, only: [:index, :bulk_search]
  before_action :load_user, only: [:show, :update, :confirm_delete_user_creations, :destroy_user_creations, :troubleshoot, :activate, :creations]
  before_action :user_is_banned, only: [:confirm_delete_user_creations, :destroy_user_creations]
  before_action :load_user_creations, only: [:confirm_delete_user_creations, :creations]

  def set_roles
    @roles = Role.assignable.distinct
  end

  def load_user
    @user = User.find_by!(login: params[:id])
  end

  def user_is_banned
    return if @user&.banned?

    flash[:error] = ts("That user is not banned!")
    redirect_to admin_users_path
  end

  def load_user_creations
    @works = @user.works.paginate(page: params[:works_page])
    @comments = @user.comments.paginate(page: params[:comments_page])
  end

  def index
    authorize User
    @role_values = @roles.map{ |role| [role.name.humanize.titlecase, role.name] }
    @role = Role.find_by(name: params[:role]) if params[:role]
    @users = User.search_by_role(
      @role, params[:name], params[:email], params[:user_id],
      inactive: params[:inactive], exact: params[:exact], page: params[:page]
    )
  end

  def bulk_search
    authorize User
    @emails = params[:emails].split if params[:emails]
    if @emails.present?
      found_users, not_found_emails, duplicates = User.search_multiple_by_email(@emails)
      @users = found_users.paginate(page: params[:page] || 1)

      if params[:download_button]
        header = [%w(Email Username)]
        found = found_users.map { |u| [u.email, u.login] }
        not_found = not_found_emails.map { |email| [email, ""] }
        send_csv_data(header + found + not_found, "bulk_user_search_#{Time.now.strftime("%Y-%m-%d-%H%M")}.csv")
        flash.now[:notice] = ts("Downloaded CSV")
      end
      @results = {
        total: @emails.size,
        searched: found_users.size + not_found_emails.size,
        found_users: found_users,
        not_found_emails: not_found_emails,
        duplicates: duplicates
      }
    else
      @results = {}
    end
  end

  # GET admin/users/1
  def show
    authorize @user
    @page_subtitle = t(".page_title", login: @user.login)
    log_items
  end

  # POST admin/users/update
  def update
    authorize @user

    attributes = permitted_attributes(@user)
    @user.email = attributes[:email] if attributes[:email].present?
    @user.roles = Role.where(id: attributes[:roles]) if attributes[:roles].present?

    if @user.save
      flash[:notice] = ts("User was successfully updated.")
    else
      flash[:error] = ts("The user %{name} could not be updated: %{errors}", name: params[:id], errors: @user.errors.full_messages.join(" "))
    end
    redirect_to request.referer || root_path
  end

  def update_next_of_kin
    @user = authorize User.find_by!(login: params[:user_login])
    kin = User.find_by(login: params[:next_of_kin_name])
    kin_email = params[:next_of_kin_email]

    fnok = @user.fannish_next_of_kin
    previous_kin = fnok&.kin
    fnok ||= @user.build_fannish_next_of_kin
    fnok.assign_attributes(kin: kin, kin_email: kin_email)

    unless fnok.changed?
      flash[:notice] = ts("No change to fannish next of kin.")
      redirect_to admin_user_path(@user) and return
    end

    # Remove FNOK that already exists.
    if fnok.persisted? && kin.blank? && kin_email.blank?
      fnok.destroy
      @user.log_removal_of_next_of_kin(previous_kin, admin: current_admin)
      flash[:notice] = ts("Fannish next of kin was removed.")
      redirect_to admin_user_path(@user) and return
    end

    if fnok.save
      @user.log_removal_of_next_of_kin(previous_kin, admin: current_admin)
      @user.log_assignment_of_next_of_kin(kin, admin: current_admin)
      flash[:notice] = ts("Fannish next of kin was updated.")
      redirect_to admin_user_path(@user)
    else
      @hide_dashboard = true
      log_items
      render :show
    end
  end

  def update_status
    @user = User.find_by!(login: params[:user_login])

    # Authorize on the manager, as we need to check which specific actions the admin can do.
    @user_manager = authorize UserManager.new(current_admin, @user, params)
    if @user_manager.save
      flash[:notice] = @user_manager.success_message
      if @user_manager.admin_action == "spamban"
        redirect_to confirm_delete_user_creations_admin_user_path(@user)
      else
        redirect_to admin_user_path(@user)
      end
    else
      flash[:error] = @user_manager.error_message
      redirect_to admin_user_path(@user)
    end
  end

  def confirm_delete_user_creations
    authorize @user
    @bookmarks = @user.bookmarks
    @collections = @user.sole_owned_collections
    @series = @user.series
  end

  def destroy_user_creations
    authorize @user

    creations = @user.works + @user.bookmarks + @user.sole_owned_collections
    creations.each do |creation|
      AdminActivity.log_action(current_admin, creation, action: "destroy spam", summary: creation.inspect)
      creation.mark_as_spam! if creation.respond_to?(:mark_as_spam!)
      creation.destroy
    end

    # comments are special and needs to be handled separately
    @user.comments.each do |comment|
      AdminActivity.log_action(current_admin, comment, action: "destroy spam", summary: comment.inspect)
      # Akismet spam procedures are skipped, since logged-in comments aren't spam-checked anyways
      comment.destroy_or_mark_deleted # comments with replies cannot be destroyed, mark deleted instead
    end

    flash[:notice] = t(".success", login: @user.login)
    redirect_to(admin_users_path)
  end

  def troubleshoot
    authorize @user

    @user.fix_user_subscriptions
    @user.set_user_work_dates
    @user.reindex_user_creations
    @user.update_works_index_timestamp!
    @user.create_log_item(options = { action: ArchiveConfig.ACTION_TROUBLESHOOT, admin_id: current_admin.id })
    flash[:notice] = ts("User account troubleshooting complete.")
    redirect_to(request.env["HTTP_REFERER"] || root_path) && return
  end

  def activate
    authorize @user

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

  def creations
    authorize @user
    @page_subtitle = t(".page_title", login: @user.login)
  end

  def log_items
    @log_items ||= @user.log_items.sort_by(&:created_at).reverse
  end
end
