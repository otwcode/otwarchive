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

  # POST admin/users/update
  def update
    @user = User.find_by(login: params[:id])
    if @user.admin_update(params[:user])
      flash[:notice] = ts("User was successfully updated.")
      redirect_to(request.env["HTTP_REFERER"] || root_path)
    else
      flash[:error] = ts("There was an error updating user %{name}", name: params[:id])
      redirect_to(request.env["HTTP_REFERER"] || root_path)
    end
  end

  def update_status
    @user = User.find_by(login: params[:user_login])
    @user_manager = UserManager.new(current_admin, params)
    if @user_manager.save
      flash[:notice] = @user_manager.success_message
      if params[:admin_action] == "spamban"
        redirect_to confirm_delete_user_creations_admin_user_path(@user)
      else
        redirect_to request.referer || root_path
      end
    else
      flash[:error] = @user_manager.error_message
      redirect_to request.referer || root_path
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
    @user.reindex_user_works
    @user.set_user_work_dates
    @user.reindex_user_bookmarks
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
