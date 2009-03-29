class UsersController < ApplicationController
  before_filter :check_user_status, :only => [:edit, :update]
  before_filter :is_owner, :only => [:edit, :update, :destroy]
  before_filter :check_account_creation_status, :only => [:new, :create]
  
  # Ensure that the current user is authorized to make changes
  def is_owner
    @user = User.find_by_login(params[:id])
    @user == current_user || access_denied
  end
  
  def check_account_creation_status
    if is_registered_user?
      flash[:error] = t('already_logged_in', :default => "You are already logged in!")
      redirect_to root_path
      return
    end
    return true if ArchiveConfig.ACCOUNT_CREATION_ENABLED 
    @invitation = Invitation.find_by_token(params[:invitation_token])
    if !@invitation
      flash[:error] = t('creation_suspended', :default => "Account creation is suspended at the moment. Please check back with us later.")
      redirect_to login_path
      return 
    elsif @invitation.used?
      flash[:error] = t('invitation_used', :default => "This invitation has already been used to create an account, sorry!")
      redirect_to login_path
      return
    end
  end
  
  def index
    if params[:letter] && params[:letter].is_a?(String)
      letter = params[:letter][0,1]
    else
      letter = Pseud::ALPHABET[0]
    end

    @authors = Pseud.alphabetical.starting_with(letter).paginate(:per_page => (params[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), :page => (params[:page] || 1))
  end 

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find_by_login(params[:id])
    if @user
      if params[:open_id_complete] then
        begin
          open_id_authentication(params[:open_id_complete])
        rescue
          render :action => "edit"
        end
      end
      @works = Work.owned_by_conditions(@user).visible.ordered('revised_at', 'DESC').limited(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
      @series = @user.series.find(:all, :limit => ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD, :order => 'series.updated_at DESC').select{|s| s.visible?(current_user)}
      @bookmarks = @user.bookmarks.visible(:limit => ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD, :order => 'bookmarks.updated_at DESC')  
    else
      flash[:error] = t('not_found', :default => "Sorry, there's no user by that name.")
      redirect_to '/'  
    end
  end
  
  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new(:invitation_token => params[:invitation_token])
    @user.email = @user.invitation.recipient_email if @user.invitation
    @hide_dashboard = true
  end
  
  # GET /users/1/edit
  def edit
    @user = User.find_by_login(params[:id])
  end
  
  # POST /users
  # POST /users.xml
  def create
    @hide_dashboard = true
    if params[:cancel_create_account]
      redirect_to root_path
    else
      @user = User.new(params[:user]) 
      unless @user.identity_url.blank?
        # normalize OpenID url before validating
        @user.identity_url = OpenIdAuthentication.normalize_url(@user.identity_url)
      end
      if @invitation
        @user.invitation = @invitation
      end
      if @user.save
        flash[:notice] = t('development_activation', :default => "During testing you can activate via <a href='{{activation_url}}'>your activation url</a>.",
                            :activation_url => activate_path(@user.activation_code)) if ENV['RAILS_ENV'] == 'development'
        render :partial => "confirmation", :layout => "application"
      else
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
        @user.activate
        self.current_user = @user
        flash[:notice] = t('signup_complete', :default => "Signup complete! This is your public profile.")
       redirect_to(@user)
      else
        flash[:error] = t('activation_key_invalid', :default => "Your activation key is invalid. Perhaps it has expired.")
       redirect_to '' 
      end
    end
  end
  
  def after_reset
    @user = User.find_by_login(params[:id])  
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find_by_login(params[:id])
    begin 
      if @user.profile
        @user.profile.update_attributes! params[:profile_attributes]
      else
        @user.profile = Profile.new(params[:profile_attributes])
        @user.profile.save!
      end
      if @user.recently_reset? && params[:change_password]
        successful_update 
      elsif !params[:user][:password].blank? && !@user.authenticated?(params[:user][:password], @user.salt) && !@user.authenticated?(params[:check][:password_check], @user.salt)
        flash[:error] = t('old_password_incorrect', :default => "Your old password was incorrect")
       unsuccessful_update
      elsif params[:user][:identity_url] != @user.identity_url && !params[:user][:identity_url].blank?
        open_id_authentication(params[:user][:identity_url])
      else
        successful_update
      end      
   rescue
      flash[:error] = t('update_failed', :default => "Your update failed; please try again.")
      render :action => "edit"
   end
  end
  
  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @hide_dashboard = true
    @user = User.find_by_login(params[:id])
    @works = @user.works.find(:all, :conditions => {:posted => true})
    if @works.blank?
      if @user.unposted_works
        @user.wipeout_unposted_works
      end
      @user.destroy
      flash[:notice] = t('successfully_deleted', :default => 'You have successfully deleted your account.')
     redirect_to(delete_confirmation_path)
    elsif params[:coauthor].blank? && params[:sole_author].blank?
      @sole_authored_works = @user.sole_authored_works
      @coauthored_works = @user.coauthored_works
      render :partial => 'delete_preview', :layout => 'application'
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
        # Orphans works where user is sole author, keeps their pseud on the orphan account
        if params[:sole_author] == 'keep_pseud'
          pseuds = @user.pseuds
          works = @sole_authored_works
          use_default = params[:use_default] == "true"        
          Creatorship.orphan(pseuds, works, use_default)
          # Orphans works where user is sole author, uses the default orphan pseud
        elsif params[:sole_author] == 'orphan_pseud'
          pseuds = @user.pseuds
          works = @sole_authored_works
          Creatorship.orphan(pseuds, works)        
          # Deletes works where user is sole author
        elsif params[:sole_author] == 'delete'
          @sole_authored_works.each do |s|
            s.destroy
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
  
 
  protected
    def successful_update
      params[:user][:recently_reset] = false
      @user.update_attributes!(params[:user]) 
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
