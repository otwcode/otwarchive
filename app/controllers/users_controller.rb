class UsersController < ApplicationController
  cache_sweeper :pseud_sweeper

  before_filter :check_user_status, only: [:edit, :update]
  before_filter :load_user, except: [:activate, :index]
  before_filter :check_ownership, except: [:activate, :browse, :index, :show]

  skip_after_filter :store_location, only: :end_first_login

  def load_user
    @user = User.find_by_login(params[:id])
    @check_ownership_of = @user
  end

  def index
    flash.keep
    redirect_to controller: :people, action: :index
  end

  # GET /users/1
  def show
    if @user.blank?
      flash[:error] = ts("Sorry, could not find this user.")
      redirect_to people_path and return
    end

    @page_subtitle = @user.login

    visible = visible_items(current_user)

    @fandoms = @fandoms.all # force eager loading
    @works = visible[:works].revealed.non_anon.order("revised_at DESC").limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
    @series = visible[:series].order("updated_at DESC").limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
    @bookmarks = visible[:bookmarks].order("updated_at DESC").limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)

    if current_user.respond_to?(:subscriptions)
      @subscription = current_user.subscriptions.where(:subscribable_id => @user.id,
                                                       :subscribable_type => 'User').first ||
                      current_user.subscriptions.build(:subscribable => @user)
    end
  end

  # GET /users/1/edit
  def edit
  end

  def changed_password
    unless params[:password] && reauthenticate
      render :change_password
      return
    end

    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]

    if @user.save
      sign_in(@user, bypass: true)
      flash[:notice] = ts('Your password has been changed')
      @user.create_log_item(action: ArchiveConfig.ACTION_PASSWORD_RESET)

      redirect_to user_profile_path(@user)
      return
    end

    render :change_password
  end

  def changed_username
    unless params[:new_login].present?
      render :change_username
      return
    end

    @new_login = params[:new_login]

    unless @user.valid_password?(params[:password])
      flash[:error] = ts('Your password was incorrect')
      render :change_username
      return
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

  def activate
    if params[:id].blank?
      flash[:error] = ts("Your activation key is missing.")
      redirect_to ''

      return
    end

    @user = User.find_by_activation_code(params[:id])

    unless @user
      flash[:error] = ts("Your activation key is invalid. If you didn't activate within 14 days, your account was deleted. Please sign up again, or contact support via the link in our footer for more help.").html_safe
      redirect_to ''

      return
    end

    if @user.confirmed?
      flash.now[:error] = ts("Your account has already been activated.")
      redirect_to @user

      return
    end

    @user.activate

    flash[:notice] = ts("Signup complete! Please log in.")

    @user.create_log_item(action: ArchiveConfig.ACTION_ACTIVATE)

    # assign over any external authors that belong to this user
    external_authors = []
    external_authors << ExternalAuthor.find_by_email(@user.email)
    @invitation = @user.invitation
    external_authors << @invitation.external_author if @invitation
    external_authors.compact!

    unless external_authors.empty?
      external_authors.each do |external_author|
        external_author.claim!(@user)
      end

      flash[:notice] += ts(" We found some works already uploaded to the Archive of Our Own that we think belong to you! You'll see them on your homepage when you've logged in.")
    end

    redirect_to(login_path)
  end

  def update
    @user.profile.update_attributes(params[:profile_attributes])

    if @user.profile.save
      flash[:notice] = ts("Your profile has been successfully updated")
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
        flash[:notice] = ts("Your email has been successfully updated")
        UserMailer.change_email(@user.id, @old_email, @new_email).deliver
        @user.create_log_item( options = {:action => ArchiveConfig.ACTION_NEW_EMAIL})
      else
        flash[:error] = ts("Email addresses don't match! Please retype and try again")
      end
    end

    render :change_email
  end

  def end_first_login
    @user.preference.update_attribute(:first_login, false)

    respond_to do |format|
      format.html { redirect_to @user and return }
      format.js
    end
  end
  
  def end_banner
    @user.preference.update_attribute(:banner_seen, true)

    respond_to do |format|
      format.html { redirect_to(request.env["HTTP_REFERER"] || root_path) and return }
      format.js
    end
  end

  def browse
    @co_authors = Pseud.order(:name).coauthor_of(@user.pseuds)
    @tag_types = %w(Fandom Character Relationship Freeform)
    @tags = @user.tags.with_scoped_count.includes(:merger)

    if params[:sort] == "count"
      @tags = @tags.order("count DESC")
    else
      @tags = @tags.order("name ASC")
    end

    @tags = @tags.group_by{|t| t.type.to_s}
  end

  private

  # Check user password of logged in user for extra security
  def reauthenticate
    return wrong_password_message(
      params[:new_email],
      ts('You must enter your password'),
      ts('You must enter your old password')
    ) if params[:password_check].blank?

    return wrong_password_message(
      params[:new_email],
      ts('Your password was incorrect'),
      ts('Your old password was incorrect')
    ) unless @user.valid_password?(params[:password_check])

    true
  end

  # Define flash message when reauthentication fails
  def wrong_password_message(condition, if_true, if_false)
    flash.now[:error] = condition ? if_true : if_false
    @wrong_password = true

    false
  end

  def visible_items(current_user)
    # NOTE: When current_user is nil, we use .visible_to_all, otherwise we use
    #       .visible_to_registered_user.
    visible_method = (current_user.nil? && current_admin.nil?) ? :visible_to_all : :visible_to_registered_user

    # hahaha omg so ugly BUT IT WORKS :P
    @fandoms = Fandom.select("tags.*, count(tags.id) as work_count").
                 joins(:direct_filter_taggings).
                 joins("INNER JOIN works ON filter_taggings.filterable_id = works.id AND filter_taggings.filterable_type = 'Work'").
                 group("tags.id").order("work_count DESC").
                 merge(Work.send(visible_method).revealed.non_anon).
                 merge(Work.joins("INNER JOIN creatorships ON creatorships.creation_id = works.id AND creatorships.creation_type = 'Work'
  INNER JOIN pseuds ON creatorships.pseud_id = pseuds.id
  INNER JOIN users ON pseuds.user_id = users.id").where("users.id = ?", @user.id))
    visible_works = @user.works.send(visible_method)
    visible_series = @user.series.send(visible_method)
    visible_bookmarks = @user.bookmarks.send(visible_method)

    {
      works: visible_works,
      series: visible_series,
      bookmarks: visible_bookmarks
    }
  end
end
