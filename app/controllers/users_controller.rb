class UsersController < ApplicationController
  before_filter :check_user_status, :only => [:edit, :update]
  before_filter :load_user, :only => [:show, :edit, :update, :destroy, :after_reset, :end_first_login, :edit_username]
  before_filter :check_ownership, :only => [:edit, :update, :destroy, :end_first_login, :edit_username]
  before_filter :check_account_creation_status, :only => [:new, :create]

  def load_user
    @user = User.find_by_login(params[:id])
    @check_ownership_of = @user
  end

  def check_account_creation_status
    if is_registered_user?
      flash[:error] = t('already_logged_in', :default => "You are already logged in!")
      redirect_to root_path
      return
    end
    token = params[:invitation_token] || (params[:user] && params[:user][:invitation_token])
    @invitation = Invitation.find_by_token(token)
    #return true if AdminSetting.account_creation_enabled?   
    if !@invitation
      flash[:error] = t('creation_suspended', :default => "Account creation is suspended at the moment. Please check back with us later.")
      redirect_to login_path
      return
    elsif @invitation.redeemed_at && @invitation.invitee
      flash[:error] = t('invitation_used', :default => "This invitation has already been used to create an account, sorry!")
      redirect_to login_path
      return
    end
  end

  def index
    redirect_to :controller => :people, :action => :index
  end

  # GET /users/1
  # very similar to show under pseuds - if you change something here, you'll probably need to change it there too
  def show
    if @user.blank?
      flash[:error] = ts("Sorry, could not find this user.")
      redirect_to people_path and return
    end
    if params[:open_id_complete] then
      begin
        open_id_authentication(params[:open_id_complete])
      rescue
        render :action => "edit"
      end
    end
    if current_user.nil?
      visible_works = @user.works.visible_to_all
      visible_series = @user.series.visible_to_all
      visible_bookmarks = @user.bookmarks.visible_to_all
    else
      visible_works = @user.works.visible_to_registered_user
      visible_series = @user.series.visible_to_registered_user
      visible_bookmarks = @user.bookmarks.visible_to_registered_user
    end
    @fandoms = @user.direct_filters.with_type("Fandom").by_name.uniq
    @works = visible_works.order("revised_at DESC").limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
    @series = visible_series.order("updated_at DESC").limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
    @bookmarks = visible_bookmarks.order("updated_at DESC").limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
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
  
  def edit_username
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
      @user.invitation_token = params[:user][:invitation_token]
      @user.age_over_13 = params[:user][:age_over_13]
      @user.terms_of_service = params[:user][:terms_of_service]
      @user.password = params[:user][:password] if params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation] if params[:user][:password_confirmation]
      @user.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      unless @user.identity_url.blank?
        # normalize OpenID url before validating
        @user.identity_url = OpenIdAuthentication.normalize_identifier(@user.identity_url)
      end
      if @user.save
        UserMailer.signup_notification(@user).deliver
        flash[:notice] = t('development_activation', :default => "During testing you can activate via <a href='%{activation_url}'>your activation url</a>.",
                            :activation_url => activate_path(@user.activation_code)) if Rails.env.development?
        render "confirmation"
      else
        if params[:user] && params[:user][:identity_url]
          params[:use_openid] = true
        end
        render :action => "new"
      end
    end
  end

  def activate
    if params[:id].blank?
      flash[:error] = t('activation_key_missing', :default => "Your activation key is missing.")
      redirect_to ''
    else
      @user = User.find_by_activation_code(params[:id])
      if @user
        if @user.active?
          flash[:error] = t('activation_key_used', :default => "Your account has already been activated.")
          redirect_to @user and return
        end
        @user.activate && UserMailer.activation(@user).deliver
        flash[:notice] = t('signup_complete', :default => "Signup complete! Please log in.")
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
          flash[:notice] += t('external_authors_claimed', 
            :default => " We found some stories already uploaded to the Archive of Our Own that we think belong to you! You can see them either in your works below or in your drafts folder.")
        end
        redirect_to(login_path)
      else
        flash[:error] = t('activation_key_invalid', :default => "Your activation key is invalid. If you didn't activate within 14 days, your account was deleted. Please sign up again.")
        redirect_to ''
      end
    end
  end

  def after_reset
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    begin
      if @user.profile
        @user.profile.update_attributes! params[:profile_attributes]
      else
        @user.profile = Profile.new(params[:profile_attributes])
        @user.profile.save!
      end
      if @user.recently_reset? && params[:change_password]
        successful_update
      elsif params[:user] && !params[:user][:password].blank? && !@user.authenticated?(params[:user][:password], @user.salt) && !@user.authenticated?(params[:check][:password_check], @user.salt)
        flash[:error] = t('old_password_incorrect', :default => "Your old password was incorrect")
        unsuccessful_update
      elsif params[:user] && params[:user][:identity_url] != @user.identity_url 
        if params[:user][:identity_url].blank?
          successful_update
        else
          open_id_authentication(params[:user][:identity_url])
        end
      elsif params['openid.mode']
        if @user.update_attribute(:identity_url, params['openid.identity'])
          flash[:notice] = t('profile_updated', :default => 'Your profile has been successfully updated.')
          redirect_to(user_profile_path(@user))
        else
          params[:use_openid] = true
          flash[:error] = "Your OpenID failed to save. Please try again."
          render :edit
        end
      elsif params[:login]
        if User.authenticate(params[:login], params[:password])
          if @user.update_attribute(:login, params[:login])
            flash[:notice] = t('edit_username_worked', :default => "Username successfully changed")
            redirect_to(user_path(@user))
          else
            flash[:error] = t('edit_username_failed', :default => "Username change failed.")
            redirect_to(url_for(:controller => :user, :action => :edit_username, :user => @user))
          end
        else
          flash[:error] = t('password_incorrect', :default => "Your password was incorrect")
          redirect_to(url_for(:controller => :user, :action => :edit_username, :user => @user))
        end
      else
        successful_update
      end
    rescue
      if params[:user] && params[:user][:identity_url]
        params[:use_openid] = true
      end
      flash[:error] = t('update_failed', :default => "Your update failed; please try again.")
      render :action => "edit"
    end
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
      flash[:notice] = t('successfully_deleted', :default => 'You have successfully deleted your account.')
     redirect_to(delete_confirmation_path)
    elsif params[:coauthor].blank? && params[:sole_author].blank?
      @sole_authored_works = @user.sole_authored_works
      @coauthored_works = @user.coauthored_works
      render 'delete_preview' and return
    elsif params[:coauthor] || params[:sole_author]
      @sole_authored_works = @user.sole_authored_works
      @coauthored_works = @user.coauthored_works
      if params[:cancel_button]
        flash[:notice] = t('deletion_canceled', :default => "Account deletion canceled.")
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
          flash[:notice] = t('successfully_deleted', :default => 'You have successfully deleted your account.')
          redirect_to(delete_confirmation_path)
        else
          flash[:error] = t('deletion_failed', :default => "Sorry, something went wrong! Please try again.")
          redirect_to(@user)
        end
      end
    end
  end

  def delete_confirmation
  end
  
  def end_first_login
    @user.preference.update_attribute(:first_login, false)
    if !(request.xml_http_request?)
      redirect_to @user
    end
  end

  protected
    def successful_update
      @user.update_attributes!(params[:user])
      @user.update_attribute(:recently_reset, false)
      flash[:notice] = t('profile_updated', :default => 'Your profile has been successfully updated.')
      redirect_to(user_profile_path(@user))
    end

    def unsuccessful_update
       raise
    end

    def open_id_authentication(openid_url)
      authenticate_with_open_id(openid_url) do |result, identity_url, registration|
        if result.successful?
          @user.update_attribute(:identity_url, identity_url)
          flash[:notice] = t('profile_updated', :default => 'Your profile has been successfully updated.')
          redirect_to(user_profile_path(@user))
        else
          flash[:error] = result.message
          raise
        end
      end
    end

end
