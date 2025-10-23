class UsersController < ApplicationController
  cache_sweeper :pseud_sweeper

  before_action :check_user_status, only: [:change_username, :changed_username]
  before_action :load_user, except: [:activate, :delete_confirmation, :index]
  before_action :check_ownership, except: [:activate, :change_username, :changed_username, :delete_confirmation, :index, :show]
  before_action :check_ownership_or_admin, only: [:change_username, :changed_username]

  def load_user
    @user = User.find_by!(login: params[:id])
    @check_ownership_of = @user
  end

  def index
    flash.keep
    redirect_to controller: :people, action: :index
  end

  # GET /users/1
  def show
    @page_subtitle = @user.login

    visible = visible_items(current_user)

    @works = visible[:works].order('revised_at DESC').limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
    @series = visible[:series].order('updated_at DESC').limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
    @bookmarks = visible[:bookmarks].order('updated_at DESC').limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
    if current_user.respond_to?(:subscriptions)
      @subscription = current_user.subscriptions.where(subscribable_id: @user.id,
                                                       subscribable_type: 'User').first ||
                      current_user.subscriptions.build(subscribable: @user)
    end
  end

  def change_email
    @page_subtitle = t(".page_title")
  end

  def change_password
    @page_subtitle = t(".page_title")
  end

  def change_username
    authorize @user if logged_in_as_admin?
    @page_subtitle = t(".page_title")
  end

  def changed_password
    unless params[:password] && reauthenticate
      render(:change_password) && return
    end

    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]

    if @user.save
      flash[:notice] = ts("Your password has been changed. To protect your account, you have been logged out of all active sessions. Please log in with your new password.")
      @user.create_log_item(action: ArchiveConfig.ACTION_PASSWORD_CHANGE)

      redirect_to(user_profile_path(@user)) && return
    else
      render(:change_password) && return
    end
  end

  def changed_username
    authorize @user if logged_in_as_admin?
    render(:change_username) && return if params[:new_login].blank?

    @new_login = params[:new_login]

    unless logged_in_as_admin? || @user.valid_password?(params[:password])
      flash[:error] = t(".user.incorrect_password_html", contact_support_link: helpers.link_to(t(".user.contact_support"), new_feedback_report_path))
      render(:change_username) && return
    end

    if @new_login == @user.login
      flash.now[:error] = t(".new_username_must_be_different")
      render :change_username and return
    end

    old_login = @user.login
    @user.login = @new_login
    @user.ticket_number = params[:ticket_number]

    if @user.save
      if logged_in_as_admin?
        flash[:notice] = t(".admin.successfully_updated")
        redirect_to admin_user_path(@user)
      else
        I18n.with_locale(@user.preference.locale_for_mails) do
          UserMailer.change_username(@user, old_login).deliver_later
        end

        flash[:notice] = t(".user.successfully_updated")
        redirect_to @user
      end
    else
      @user.reload
      render :change_username
    end
  end

  def activate
    if params[:id].blank?
      flash[:error] = ts('Your activation key is missing.')
      redirect_to root_path

      return
    end

    @user = User.find_by(confirmation_token: params[:id])

    unless @user
      flash[:error] = ts("Your activation key is invalid. If you didn't activate within #{AdminSetting.current.days_to_purge_unactivated * 7} days, your account was deleted. Please sign up again, or contact support via the link in our footer for more help.").html_safe
      redirect_to root_path

      return
    end

    if @user.active?
      flash[:error] = ts("Your account has already been activated.")
      redirect_to @user

      return
    end

    @user.activate

    flash[:notice] = ts("Account activation complete! Please log in.")

    @user.create_log_item(action: ArchiveConfig.ACTION_ACTIVATE)

    # assign over any external authors that belong to this user
    external_authors = []
    external_authors << ExternalAuthor.find_by(email: @user.email)
    @invitation = @user.invitation
    external_authors << @invitation.external_author if @invitation
    external_authors.compact!

    unless external_authors.empty?
      external_authors.each do |external_author|
        external_author.claim!(@user)
      end

      flash[:notice] += ts(" We found some works already uploaded to the Archive of Our Own that we think belong to you! You'll see them on your homepage when you've logged in.")
    end

    redirect_to(new_user_session_path)
  end

  def confirm_change_email
    @page_subtitle = t(".browser_title")

    render :change_email and return unless reauthenticate

    if params[:new_email].blank?
      flash.now[:error] = t("users.confirm_change_email.blank_email")
      render :change_email and return
    end

    @new_email = params[:new_email]

    # Please note: This comparison is not technically correct. According to
    # RFC 5321, the local part of an email address is case sensitive, while the
    # domain is case insensitive. That said, all major email providers treat
    # the local part as case insensitive, so it would probably cause more
    # confusion if we did this correctly.
    #
    # Also, email addresses are validated on the client, and will only contain
    # a limited subset of ASCII, so we don't need to do a unicode casefolding pass.
    if @new_email.downcase == @user.email.downcase
      flash.now[:error] = t("users.confirm_change_email.same_as_current")
      render :change_email and return
    end

    if @new_email.downcase != params[:email_confirmation].downcase
      flash.now[:error] = t("users.confirm_change_email.nonmatching_email")
      render :change_email and return
    end

    old_email = @user.email
    @user.email = @new_email
    return if @user.valid?(:update)

    # Make sure that on failure, the form doesn't show the new invalid email as the current one
    @user.email = old_email
    render :change_email
  end

  def changed_email
    new_email = params[:new_email]

    old_email = @user.email
    @user.email = new_email

    if @user.save
      I18n.with_locale(@user.preference.locale_for_mails) do
        UserMailer.change_email(@user.id, old_email, new_email).deliver_later
      end
    else
      # Make sure that on failure, the form still shows the old email as the "current" one.
      @user.email = old_email
    end

    render :change_email
  end

  # GET /users/1/reconfirm_email?confirmation_token=abcdef
  def reconfirm_email
    confirmed_user = User.confirm_by_token(params[:confirmation_token])

    if confirmed_user.errors.empty?
      flash[:notice] = t(".success")
    else
      flash[:error] = t(".invalid_token")
    end

    redirect_to change_email_user_path(@user)
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @hide_dashboard = true
    @works = @user.works.where(posted: true)
    @sole_owned_collections = @user.sole_owned_collections

    if @works.empty? && @sole_owned_collections.empty?
      @user.wipeout_unposted_works
      @user.destroy_empty_series

      @user.destroy
      flash[:notice] = ts('You have successfully deleted your account.')

      redirect_to(delete_confirmation_path)
    elsif params[:coauthor].blank? && params[:sole_author].blank?
      @sole_authored_works = @user.sole_authored_works
      @coauthored_works = @user.coauthored_works

      render('delete_preview') && return
    elsif params[:coauthor] || params[:sole_author]
      destroy_author
    end
  end

  def delete_confirmation
    redirect_to user_path(current_user) if logged_in?
  end

  def end_first_login
    @user.preference.update_attribute(:first_login, false)

    respond_to do |format|
      format.html { redirect_to(@user) && return }
      format.js
    end
  end

  def end_banner
    @user.preference.update_attribute(:banner_seen, true)

    respond_to do |format|
      format.html { redirect_back_or_to root_path and return }
      format.js
    end
  end

  def end_tos_prompt
    @user.update_attribute(:accepted_tos_version, @current_tos_version)
    head :no_content
  end

  private

  def reauthenticate
    if params[:password_check].blank?
      return wrong_password!(params[:new_email],
                             t("users.confirm_change_email.blank_password"),
                             t("users.changed_password.blank_password"))
    end

    if @user.valid_password?(params[:password_check])
      true
    else
      wrong_password!(params[:new_email],
                      t("users.confirm_change_email.wrong_password_html", contact_support_link: helpers.link_to(t("users.confirm_change_email.contact_support"), new_feedback_report_path)),
                      t("users.changed_password.wrong_password_html", contact_support_link: helpers.link_to(t("users.changed_password.contact_support"), new_feedback_report_path)))
    end
  end

  def wrong_password!(condition, if_true, if_false)
    flash.now[:error] = condition ? if_true : if_false
    @wrong_password = true

    false
  end

  def visible_items(current_user)
    # NOTE: When current_user is nil, we use .visible_to_all, otherwise we use
    #       .visible_to_registered_user.
    visible_method = current_user.nil? && current_admin.nil? ? :visible_to_all : :visible_to_registered_user

    visible_works = @user.works.send(visible_method)
    visible_series = @user.series.send(visible_method)
    visible_bookmarks = @user.bookmarks.send(visible_method)

    visible_works = visible_works.revealed.non_anon
    visible_series = visible_series.exclude_anonymous
    @fandoms = if @user == User.orphan_account
                 []
               else
                 Fandom.select("tags.*, count(DISTINCT works.id) as work_count").
                   joins(:filtered_works).group("tags.id").merge(visible_works).
                   where(filter_taggings: { inherited: false }).
                   order('work_count DESC').load
               end

    {
      works: visible_works,
      series: visible_series,
      bookmarks: visible_bookmarks
    }
  end

  def destroy_author
    @sole_authored_works = @user.sole_authored_works
    @coauthored_works = @user.coauthored_works

    if params[:cancel_button]
      flash[:notice] = ts('Account deletion canceled.')
      redirect_to user_profile_path(@user)

      return
    end

    if params[:coauthor] == 'keep_pseud' || params[:coauthor] == 'orphan_pseud'
      # Orphans co-authored works.

      pseuds = @user.pseuds
      works = @coauthored_works

      # We change the pseud to the default orphan pseud if use_default is true.
      use_default = params[:use_default] == 'true' || params[:coauthor] == 'orphan_pseud'

      Creatorship.orphan(pseuds, works, use_default)

    elsif params[:coauthor] == 'remove'
      # Removes user as an author from co-authored works

      @coauthored_works.each do |w|
        w.remove_author(@user)
      end
    end

    if params[:sole_author] == 'keep_pseud' || params[:sole_author] == 'orphan_pseud'
      # Orphans works where user is the sole author.

      pseuds = @user.pseuds
      works = @sole_authored_works

      # We change the pseud to default orphan pseud if use_default is true.
      use_default = params[:use_default] == 'true' || params[:sole_author] == 'orphan_pseud'

      Creatorship.orphan(pseuds, works, use_default)
      Collection.orphan(pseuds, @sole_owned_collections, default: use_default)
    elsif params[:sole_author] == 'delete'
      # Deletes works where user is sole author
      @sole_authored_works.each(&:destroy)

      # Deletes collections where user is sole author
      @sole_owned_collections.each(&:destroy)
    end

    @works = @user.works.where(posted: true)

    if @works.blank?
      @user.wipeout_unposted_works
      @user.destroy_empty_series

      @user.destroy

      flash[:notice] = ts('You have successfully deleted your account.')
      redirect_to(delete_confirmation_path)
    else
      flash[:error] = ts('Sorry, something went wrong! Please try again.')
      redirect_to(@user)
    end
  end
end
