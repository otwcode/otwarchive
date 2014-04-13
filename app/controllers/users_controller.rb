class UsersController < ApplicationController
  cache_sweeper :pseud_sweeper

  before_filter :check_user_status, :only => [:edit, :update]
  before_filter :load_user, :except => [:activate, :create, :delete_confirmation, :index, :new]
  before_filter :check_ownership, :except => [:activate, :browse, :create, :delete_confirmation, :index, :new, :show]  
  before_filter :check_account_creation_status, :only => [:new, :create]
  skip_before_filter :store_location, :only => [:end_first_login]


  # This is meant to rescue from race conditions that sometimes occur on user creation
  # The unique index on login (database level) prevents the duplicate user from being created,
  # but ideally we can still send the user the activation code and show them the confirmation page
  rescue_from ActiveRecord::RecordNotUnique do |exception|
    # ensure we actually have a duplicate user situation
    if exception.message =~ /Mysql2?::Error: Duplicate entry/i &&
      @user && User.count(:conditions => {:login => @user.login}) > 0 &&
      # and that we can find the original, valid user record
      (@user = User.find_by_login(@user.login))
        notify_and_show_confirmation_screen
    else
      # re-raise the exception and make it catchable by Rails and Airbrake
      # (see http://www.simonecarletti.com/blog/2009/11/re-raise-a-ruby-exception-in-a-rails-rescue_from-statement/)
      rescue_action_without_handler(exception)
    end
  end

  def load_user
    @user = User.find_by_login(params[:id])
    @check_ownership_of = @user
  end

  def check_account_creation_status
    if is_registered_user?
      flash[:error] = ts("You are already logged in!")
      redirect_to root_path and return
    end
    token = params[:invitation_token]
    if token.blank?
      if !@admin_settings.account_creation_enabled?
        flash[:error] = ts("You need an invitation to sign up.")
        redirect_to invite_requests_path and return
      end
    else
      invitation = Invitation.find_by_token(token)
      if !invitation
        flash[:error] = ts("There was an error with your invitation token, please contact support")
        redirect_to new_feedback_report_path and return
      elsif invitation.redeemed_at && invitation.invitee
        flash[:error] = ts("This invitation has already been used to create an account, sorry!")
        redirect_to root_path and return
      end
    end
  end

  def index
    flash.keep
    redirect_to :controller => :people, :action => :index
  end

  # GET /users/1
  def show
    if @user.blank?
      flash[:error] = ts("Sorry, could not find this user.")
      redirect_to people_path and return
    end
    @page_subtitle = @user.login

    # very similar to show under pseuds - if you change something here, change it there too
    if current_user.nil?
      # hahaha omg so ugly BUT IT WORKS :P
      @fandoms = Fandom.select("tags.*, count(tags.id) as work_count").
                   joins(:direct_filter_taggings).
                   joins("INNER JOIN works ON filter_taggings.filterable_id = works.id AND filter_taggings.filterable_type = 'Work'").
                   group("tags.id").order("work_count DESC").
                   merge(Work.visible_to_all.revealed.non_anon).
                   merge(Work.joins("INNER JOIN creatorships ON creatorships.creation_id = works.id AND creatorships.creation_type = 'Work'
    INNER JOIN pseuds ON creatorships.pseud_id = pseuds.id
    INNER JOIN users ON pseuds.user_id = users.id").where("users.id = ?", @user.id))
      visible_works = @user.works.visible_to_all
      visible_series = @user.series.visible_to_all
      visible_bookmarks = @user.bookmarks.visible_to_all
    else
      @fandoms = Fandom.select("tags.*, count(tags.id) as work_count").
                   joins(:direct_filter_taggings).
                   joins("INNER JOIN works ON filter_taggings.filterable_id = works.id AND filter_taggings.filterable_type = 'Work'").
                   group("tags.id").order("work_count DESC").
                   merge(Work.visible_to_registered_user.revealed.non_anon).
                   merge(Work.joins("INNER JOIN creatorships ON creatorships.creation_id = works.id AND creatorships.creation_type = 'Work'
    INNER JOIN pseuds ON creatorships.pseud_id = pseuds.id
    INNER JOIN users ON pseuds.user_id = users.id").where("users.id = ?", @user.id))
      visible_works = @user.works.visible_to_registered_user
      visible_series = @user.series.visible_to_registered_user
      visible_bookmarks = @user.bookmarks.visible_to_registered_user
    end

    @fandoms = @fandoms.all # force eager loading
    @works = visible_works.revealed.non_anon.order("revised_at DESC").limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
    @series = visible_series.order("updated_at DESC").limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
    @bookmarks = visible_bookmarks.order("updated_at DESC").limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)

    if current_user.respond_to?(:subscriptions)
      @subscription = current_user.subscriptions.where(:subscribable_id => @user.id,
                                                       :subscribable_type => 'User').first ||
                      current_user.subscriptions.build(:subscribable => @user)
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    if params[:invitation_token]
      @invitation = Invitation.find_by_token(params[:invitation_token])
      @user.invitation_token = @invitation.token
      @user.email = @invitation.invitee_email
    end
    @hide_dashboard = true
  end

  # GET /users/1/edit
  def edit
  end

  def change_password
    if params[:password]
      unless @user.recently_reset? || reauthenticate
        render :change_password and return
      end
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]
      @user.recently_reset = false
      if @user.save
        flash[:notice] = ts("Your password has been changed")
        @user.create_log_item( options = {:action => ArchiveConfig.ACTION_PASSWORD_RESET})
        redirect_to user_profile_path(@user) and return
      else
        render :change_password and return
      end
    end
  end

  def change_username
    if params[:new_login]
      @new_login = params[:new_login]
      session = UserSession.new(:login => @user.login, :password => params[:password])
      if !session.valid?
        flash[:error] = ts("Your password was incorrect")
      else
        user = User.find_by_login(@new_login)
        if user && (user != @user)
          flash[:error] = ts("User name already taken.")
        else
          old_login = @user.login
          @user.login = @new_login
          if @user.save
            flash[:notice] = ts("Your user name was changed")

            new_pseud = Pseud.where(:name => @new_login, :user_id => @user.id).first
            old_pseud = Pseud.where(:name => old_login, :user_id => @user.id).first
            if new_pseud
              # do nothing - they already have the matching pseud
            elsif old_pseud
              # change the old pseud to match
              old_pseud.update_attribute(:name, @new_login)
            else
              # shouldn't be able to get here, but just in case
              Pseud.create(:name => @new_login, :user_id => @user.id)
            end

            redirect_to @user and return
          else
            @user.errors.clear
            @user.reload
            flash[:error] = ts("User name must begin and end with a letter or number; it may also contain underscores but no other characters.")
          end
        end
      end
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @hide_dashboard = true
    if params[:cancel_create_account]
      redirect_to root_path
    else
      @user = User.new
      @user.login = params[:user][:login]
      @user.email = params[:user][:email]
      @user.invitation_token = params[:invitation_token]
      @user.age_over_13 = params[:user][:age_over_13]
      @user.terms_of_service = params[:user][:terms_of_service]
      @user.password = params[:user][:password] if params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation] if params[:user][:password_confirmation]
      @user.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      if @user.save
        notify_and_show_confirmation_screen
      else
        render :action => "new"
      end
    end
  end

  def notify_and_show_confirmation_screen
    # deliver synchronously to avoid getting caught in backed-up mail queue
    UserMailer.signup_notification(@user.id).deliver! 
    flash[:notice] = ts("During testing you can activate via <a href='%{activation_url}'>your activation url</a>.",
                        :activation_url => activate_path(@user.activation_code)).html_safe if Rails.env.development?
    render "confirmation"
  end

  def activate
    if params[:id].blank?
      flash[:error] = ts("Your activation key is missing.")
      redirect_to ''
    else
      @user = User.find_by_activation_code(params[:id])
      if @user
        if @user.active?
          flash.now[:error] = ts("Your account has already been activated.")
          redirect_to @user and return
        end
        # this is just a confirmation and it's ok if it gets delayed
        @user.activate && UserMailer.activation(@user.id).deliver
        flash[:notice] = ts("Signup complete! Please log in.")
        @user.create_log_item( options = {:action => ArchiveConfig.ACTION_ACTIVATE})
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
      else
        flash[:error] = ts("Your activation key is invalid. If you didn't activate within 14 days, your account was deleted. Please sign up again, or contact support via the link in our footer for more help.").html_safe
        redirect_to ''
      end
    end
  end

  def update
    @user.profile.update_attributes(params[:profile_attributes])
    if @user.profile.save
      flash[:notice] = ts("Your profile has been successfully updated")
      redirect_to edit_user_path(@user)
    else
      render :edit
    end
  end
  
  def change_email
    if params[:new_email].blank?
      render :change_email and return
    else
      if !reauthenticate
        render :change_email and return
      else
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
          render :change_email and return
        end
      end
    end
    render :change_email and return
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @hide_dashboard = true
    @works = @user.works.find(:all, :conditions => {:posted => true})
    @sole_owned_collections = @user.collections.delete_if {|collection| (collection.all_owners - @user.pseuds).size > 0}
    if @works.empty? && @sole_owned_collections.empty?
      if @user.unposted_works
        @user.wipeout_unposted_works
      end
      @user.destroy
      flash[:notice] = ts('You have successfully deleted your account.')
     redirect_to(delete_confirmation_path)
    elsif params[:coauthor].blank? && params[:sole_author].blank?
      @sole_authored_works = @user.sole_authored_works
      @coauthored_works = @user.coauthored_works
      render 'delete_preview' and return
    elsif params[:coauthor] || params[:sole_author]
      @sole_authored_works = @user.sole_authored_works
      @coauthored_works = @user.coauthored_works
      if params[:cancel_button]
        flash[:notice] = ts("Account deletion canceled.")
       redirect_to user_profile_path(@user)
      else
        # Orphans co-authored works, keeps the user's pseud on the orphan account
        if params[:coauthor] == 'keep_pseud'
          pseuds = @user.pseuds
          works = @coauthored_works
          use_default = params[:use_default] == "true"
          Creatorship.orphan(pseuds, works, use_default)
          # Orphans co-authored works, changes pseud to the default orphan pseud
        elsif params[:coauthor] == 'orphan_pseud'
          pseuds = @user.pseuds
          works = @coauthored_works
          Creatorship.orphan(pseuds, works)
          # Removes user as an author from co-authored works
        elsif params[:coauthor] == 'remove'
          @coauthored_works.each do |w|
            pseuds_with_author_removed = w.pseuds - @user.pseuds
            w.pseuds = pseuds_with_author_removed
            w.save
            w.chapters.each do |c|
              c.pseuds = c.pseuds - @user.pseuds
              if c.pseuds.empty?
                c.pseuds = w.pseuds
              end
              c.save
            end
          end
        end
        if params[:sole_author] == 'keep_pseud'
          # Orphans works where user is sole author, keeps their pseud on the orphan account
          pseuds = @user.pseuds
          works = @sole_authored_works
          use_default = params[:use_default] == "true"
          Creatorship.orphan(pseuds, works, use_default)
          Collection.orphan(pseuds, @sole_owned_collections, use_default)
        elsif params[:sole_author] == 'orphan_pseud'
          # Orphans works where user is sole author, uses the default orphan pseud
          pseuds = @user.pseuds
          works = @sole_authored_works
          Creatorship.orphan(pseuds, works)
          Collection.orphan(pseuds, @sole_owned_collections)
        elsif params[:sole_author] == 'delete'
          # Deletes works where user is sole author
          @sole_authored_works.each do |s|
            s.destroy
          end
          # Deletes collections where user is sole author
          @sole_owned_collections.each do |c|
            c.destroy
          end
        end
        @works = @user.works.find(:all, :conditions => {:posted => true})
        if @works.blank?
          if @user.unposted_works
            @user.wipeout_unposted_works
          end
          @user.destroy
          flash[:notice] = ts('You have successfully deleted your account.')
          redirect_to(delete_confirmation_path)
        else
          flash[:error] = ts("Sorry, something went wrong! Please try again.")
          redirect_to(@user)
        end
      end
    end
  end

  def delete_confirmation
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

  def reauthenticate
    if !params[:password_check].blank?
      session = UserSession.new(:login => @user.login, :password => params[:password_check])
      if session.valid?
        return true
      else
        if params[:new_email]
          flash.now[:error] = ts("Your password was incorrect")
        else
          flash.now[:error] = ts("Your old password was incorrect")
        end
        @wrong_password = true
        return false
      end
    else
      if params[:new_email]
        flash.now[:error] = ts("You must enter your password")
      else
        flash.now[:error] = ts("You must enter your old password")
      end
      @wrong_password = true
      return false
    end
  end
end
