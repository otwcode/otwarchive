class UsersController < ApplicationController
  cache_sweeper :pseud_sweeper

  before_action :check_user_status, only: [:edit, :update]
  before_action :load_user, except: [:activate, :delete_confirmation, :index]
  before_action :check_ownership, except: [:activate, :delete_confirmation, :index, :show]
  skip_before_action :store_location, only: [:end_first_login]

  # This is meant to rescue from race conditions that sometimes occur on user creation
  # The unique index on login (database level) prevents the duplicate user from being created,
  # but ideally we can still send the user the activation code and show them the confirmation page
  rescue_from ActiveRecord::RecordNotUnique do |exception|
    # ensure we actually have a duplicate user situation
    if exception.message =~ /Mysql2?::Error: Duplicate entry/i &&
       @user && User.count(conditions: { login: @user.login }) > 0 &&
       # and that we can find the original, valid user record
       (@user = User.find_by(login: @user.login))
      notify_and_show_confirmation_screen
    else
      # re-raise the exception and make it catchable by Rails and Airbrake
      # (see http://www.simonecarletti.com/blog/2009/11/re-raise-a-ruby-exception-in-a-rails-rescue_from-statement/)
      rescue_action_without_handler(exception)
    end
  end

  def load_user
    @user = User.find_by(login: params[:id])
    @check_ownership_of = @user
  end

  def index
    flash.keep
    redirect_to controller: :people, action: :index
  end

  # GET /users/1
  def show
    if @user.blank?
      flash[:error] = ts('Sorry, could not find this user.')
      redirect_to(search_people_path) && return
    end

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

  # GET /users/1/edit
  def edit
  end

  def changed_password
    unless params[:password] && reauthenticate
      render(:change_password) && return
    end

    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]

    if @user.save
      flash[:notice] = ts("Your password has been changed. To protect your account, you have been logged out of all active sessions. Please log in with your new password.")
      @user.create_log_item(options = { action: ArchiveConfig.ACTION_PASSWORD_RESET })

      redirect_to(user_profile_path(@user)) && return
    else
      render(:change_password) && return
    end
  end

  def changed_username
    render(:change_username) && return unless params[:new_login].present?

    @new_login = params[:new_login]

    unless @user.valid_password?(params[:password])
      flash[:error] = ts('Your password was incorrect')
      render(:change_username) && return
    end

    @user.login = @new_login

    if @user.save
      flash[:notice] = ts('Your user name has been successfully updated.')
      redirect_to @user
    else
      @user.reload
      render :change_username
    end
  end

  def notify_and_show_confirmation_screen
    # deliver synchronously to avoid getting caught in backed-up mail queue
    UserMailer.signup_notification(@user.id).deliver_now

    flash[:notice] = ts("During testing you can activate via <a href='%{activation_url}'>your activation url</a>.",
                        activation_url: activate_path(@user.confirmation_token)).html_safe if Rails.env.development?

    render 'confirmation'
  end

  def activate
    if params[:id].blank?
      flash[:error] = ts('Your activation key is missing.')
      redirect_to root_path

      return
    end

    @user = User.find_by(confirmation_token: params[:id])

    unless @user
      flash[:error] = ts("Your activation key is invalid. If you didn't activate within 14 days, your account was deleted. Please sign up again, or contact support via the link in our footer for more help.").html_safe
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

  def update
    @user.profile.update_attributes(profile_params)

    if @user.profile.save
      flash[:notice] = ts('Your profile has been successfully updated')
      redirect_to user_profile_path(@user)
    else
      render :edit
    end
  end

  def changed_email
    if !params[:new_email].blank? && reauthenticate
      @old_email = @user.email
      @user.email = params[:new_email]
      @new_email = params[:new_email]
      @confirm_email = params[:email_confirmation]

      if @new_email == @confirm_email && @user.save
        flash[:notice] = ts('Your email has been successfully updated')
        UserMailer.change_email(@user.id, @old_email, @new_email).deliver_later
        @user.create_log_item(options = { action: ArchiveConfig.ACTION_NEW_EMAIL })
      else
        flash[:error] = ts("Email addresses don't match! Please retype and try again")
      end
    end

    render :change_email
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @hide_dashboard = true
    @works = @user.works.where(posted: true)
    @sole_owned_collections = @user.collections.to_a.delete_if { |collection| !(collection.all_owners - @user.pseuds).empty? }

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
      format.html { redirect_to(request.env['HTTP_REFERER'] || root_path) && return }
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
                             ts('You must enter your password'),
                             ts('You must enter your old password'))
    end

    if @user.valid_password?(params[:password_check])
      true
    else
      wrong_password!(params[:new_email],
                      ts('Your password was incorrect'),
                      ts('Your old password was incorrect'))
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
      Collection.orphan(pseuds, @sole_owned_collections, use_default)
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

  private

  def user_params
    params.require(:user).permit(
      :login, :email, :age_over_13, :terms_of_service,
      :password, :password_confirmation
    )
  end

  def profile_params
    params.require(:profile_attributes).permit(
      :title, :location, :"date_of_birth(1i)", :"date_of_birth(2i)",
      :"date_of_birth(3i)", :date_of_birth, :about_me
    )
  end
end
