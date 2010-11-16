# eventually for exporting to Excel TSV format
# require 'iconv'

class ChallengeSignupsController < ApplicationController

  before_filter :users_only, :except => [:summary, :display_summary]
  before_filter :load_collection, :except => [:index]
  before_filter :load_challenge, :except => [:index]
  before_filter :load_signup_from_id, :only => [:show, :edit, :update, :destroy]
  before_filter :allowed_to_destroy, :only => [:destroy]
  before_filter :signup_owner_only, :only => [:edit, :update]
  before_filter :maintainer_or_signup_owner_only, :only => [:show]
  before_filter :check_signup_open, :only => [:new, :create, :edit, :update]

  def load_challenge
    @challenge = @collection.challenge
    no_challenge and return unless @challenge
  end

  def no_challenge
    flash[:error] = t('challenges.no_challenge', :default => "What challenge did you want to sign up for?")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end
  
  def check_signup_open
    signup_closed and return unless (@challenge.signup_open || @collection.user_is_owner?(current_user)) 
  end

  def signup_closed
    flash[:error] = t('challenge_signups.signup_closed', :default => "Signup is currently closed: please contact a moderator for help.")
    redirect_to @collection rescue redirect_to '/'
    false
  end

  def signup_owner_only
    not_signup_owner and return unless (@challenge_signup.pseud.user == current_user || (!@challenge.signup_open && @collection.user_is_owner?(current_user)))
  end
  
  def maintainer_or_signup_owner_only
    not_allowed and return unless (@challenge_signup.pseud.user == current_user || @collection.user_is_maintainer?(current_user))
  end

  def not_signup_owner
    flash[:error] = t('challenge_signups.not_owner', :default => "You can't edit someone else's signup!")
    redirect_to @collection
    false
  end
  
  def allowed_to_destroy
    @challenge_signup.user_allowed_to_destroy?(current_user) || not_allowed
  end
  
  def not_allowed
    flash[:error] = t('challenge_signups.not_allowed', :default => "Sorry, you're not allowed to do that.")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end

  def load_signup_from_id
    @challenge_signup = ChallengeSignup.find(params[:id])
    no_signup and return unless @challenge_signup
  end

  def no_signup
    flash[:error] = t('challenge_signups.no_signup', :default => "What signup did you want to work on?")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end
  
  #### ACTIONS

  def index
    if params[:user_id] && (@user = User.find_by_login(params[:user_id]))
      if current_user == @user
        @challenge_signups = @user.challenge_signups
        render :action => :index and return
      else
        flash[:error] = t('challenge_signups.not_allowed_to_see_other', :default => "You aren't allowed to see that user's signups.")
        redirect_to '/' and return
      end
    else
      load_collection 
      load_challenge if @collection
      return false unless @challenge
    end
      
    # using respond_to in order to provide Excel output
    # see below for export_excel method
    respond_to do |format|
      format.html {
          if @challenge.user_allowed_to_see_signups?(current_user)
            @challenge_signups = @collection.signups.joins(:pseud).paginate(:page => params[:page], :per_page => 20, :order => "pseuds.name")
          else
            @challenge_signups = @collection.signups.by_user(current_user)
          end
      }
      format.xls {
        if @challenge.user_allowed_to_see_signups?(current_user)
          params[:show_urls] = true
          params[:show_descriptions] = true
          @challenge_signups = @collection.signups
          export_html
        end
      }
    end    
  end
  
  def summary
    if @collection.signups.count < (ArchiveConfig.ANONYMOUS_THRESHOLD_COUNT/2)
      flash.now[:notice] = ts("Summary does not appear until at least %{count} signups have been made!", :count => ((ArchiveConfig.ANONYMOUS_THRESHOLD_COUNT/2)))
    elsif @collection.signups.count > ArchiveConfig.MAX_SIGNUPS_FOR_LIVE_SUMMARY
      # too many signups in this collection to show the summary page "live"
      if !File.exists?(ChallengeSignup.summary_file(@collection)) || 
        (@collection.challenge.signup_open? && File.new(ChallengeSignup.summary_file(@collection)).mtime < 1.hour.ago)
        # either the file is missing, or signup is open and it's more than an hour old
        # start a delayed job to generate the page
        if ArchiveConfig.NO_DELAYS
          ChallengeSignup.generate_summary(@collection)
        else
          ChallengeSignup.delay.generate_summary(@collection)
        end
      end
      redirect_to display_summary_collection_signups_path(@collection)
    else
      # generate it on the fly
      @tag_type, @summary_tags = ChallengeSignup.generate_summary_tags(@collection)
      @generated_live = true
    end
  end
  
  def display_summary
  end
  
  def show
  end

  def new
    if (@challenge_signup = ChallengeSignup.in_collection(@collection).by_user(current_user).first)
      flash[:notice] = t('challenge_signups.already_signed_up', :default => "You are already signed up for this challenge. You can edit your signup below.")
      redirect_to edit_collection_signup_path(@collection, @challenge_signup)
    else
      @challenge_signup = ChallengeSignup.new
    end
  end

  def edit
  end

  def create
    @challenge_signup = ChallengeSignup.new(params[:challenge_signup])
    @challenge_signup.pseud = current_user.default_pseud unless @challenge_signup.pseud
    @challenge_signup.collection = @collection
    # we check validity first to prevent saving tag sets if invalid
    if @challenge_signup.valid? && @challenge_signup.save
      flash[:notice] = 'Signup was successfully created.'
      redirect_to collection_signup_path(@collection, @challenge_signup)
    else
      render :action => :new
    end
  end

  def update
    if @challenge_signup.update_attributes(params[:challenge_signup])
      flash[:notice] = 'Signup was successfully updated.'
      redirect_to collection_signup_path(@collection, @challenge_signup)
    else
      render :action => :edit
    end
  end

  def destroy
    unless @challenge.signup_open || @collection.user_is_maintainer?(current_user)
      flash[:error] = t('challenge_signups.cannot_delete', :default => "You cannot delete your signup after signups are closed. Please contact a moderator for help.")
    else 
      @challenge_signup.destroy
      flash[:notice] = 'Challenge signup was deleted.'
    end
    if @collection.user_is_maintainer?(current_user)
      redirect_to collection_signups_path(@collection)
    else
      redirect_to @collection
    end
  end
  
  
protected
  # eventually for exporting to excel tsv format
  # BOM = "\377\376" #Byte Order Mark
  # 
  # def export_tsv(signups)
  #   filename = "#{@collection.name}_signups_#{Time.now.strftime('%Y-%m-%d-%H%M')}.tsv"
  #   content = signups.collect {|signup| signup.to_tsv}.join("\n")
  #   content = BOM + Iconv.conv("utf-16le", "utf-8", content)
  #   send_data content, :filename => filename
  # end

  # We just export an HTML table, but we give it the xls suffix to have Excel/Open Office recognize it correctly
  def export_html
    @page_title = "#{@collection.name} Signups at #{Time.now.strftime('%Y-%m-%d-%H%M')}"
    @hide_navigation = true
    filename = "#{@collection.name}_signups_#{Time.now.strftime('%Y-%m-%d-%H%M')}.xls"
    content = render_to_string(:template => "challenge_signups/index.html", :layout => 'barebones.html')
    send_data content, :filename => filename
  end
  
  
end
