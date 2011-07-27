class PromptsController < ApplicationController

  before_filter :users_only
  before_filter :load_collection, :except => [:index]
  before_filter :load_challenge, :except => [:index]
  before_filter :promptmeme_only, :except => [:index, :new]
  before_filter :load_prompt_from_id, :only => [:show, :edit, :update, :destroy]
  before_filter :allowed_to_destroy, :only => [:destroy]
  before_filter :signup_owner_only, :only => [:edit, :update]
  before_filter :maintainer_or_signup_owner_only, :only => [:show]
  before_filter :check_signup_open, :only => [:new, :create, :edit, :update]

  def promptmeme_only
    unless @collection.challenge_type == "PromptMeme"
      flash[:error] = ts("Only available for prompt meme challenges, not gift exchanges")
      redirect_to collection_path(@collection) rescue redirect_to '/'
    end
  end
  
  def load_challenge
    @challenge = @collection.challenge
    no_challenge and return unless @challenge
  end

  def no_challenge
    flash[:error] = ts("What challenge did you want to sign up for?")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end

  def check_signup_open
    signup_closed and return unless (@challenge.signup_open || @collection.user_is_owner?(current_user) || @collection.user_is_moderator?(current_user))
  end

  def signup_closed
    flash[:error] = ts("Signup is currently closed: please contact a moderator for help.")
    redirect_to @collection rescue redirect_to '/'
    false
  end

  def signup_owner_only
    not_signup_owner and return unless (@challenge_signup.pseud.user == current_user || (@collection.challenge_type == "GiftExchange" && !@challenge.signup_open && @collection.user_is_owner?(current_user)))
  end

  def maintainer_or_signup_owner_only
    not_allowed and return unless (@challenge_signup.pseud.user == current_user || @collection.user_is_maintainer?(current_user))
  end

  def not_signup_owner
    flash[:error] = ts("You can't edit someone else's signup!")
    redirect_to @collection
    false
  end

  def allowed_to_destroy
    @challenge_signup.user_allowed_to_destroy?(current_user) || not_allowed
  end

  def not_allowed
    flash[:error] = ts("Sorry, you're not allowed to do that.")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end

  def load_prompt_from_id
    @prompt = Prompt.find(params[:id])
    @challenge_signup = @prompt.challenge_signup
    no_prompt and return unless @prompt
  end

  def no_prompt
    flash[:error] = ts("What prompt did you want to work on?")
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
        flash[:error] = ts("You aren't allowed to see that user's signups.")
        redirect_to '/' and return
      end
    else
      load_collection
      load_challenge if @collection
      return false unless @challenge
    end

    if @challenge.user_allowed_to_see_signups?(current_user)
      @challenge_signups = @collection.signups.joins(:pseud).paginate(:page => params[:page], :per_page => 20, :order => "pseuds.name")
    elsif params[:user_id] && (@user = User.find_by_login(params[:user_id]))
      @challenge_signups = @collection.signups.by_user(current_user)
    else
      not_allowed
    end
  end

  def summary
    if @collection.signups.count < (ArchiveConfig.ANONYMOUS_THRESHOLD_COUNT/2)
      flash.now[:notice] = ts("Summary does not appear until at least %{count} signups have been made!", :count => ((ArchiveConfig.ANONYMOUS_THRESHOLD_COUNT/2)))
    elsif @collection.signups.count > ArchiveConfig.MAX_SIGNUPS_FOR_LIVE_SUMMARY
      # too many signups in this collection to show the summary page "live"
      if !File.exists?(ChallengeSignup.summary_file(@collection)) ||
          (@collection.challenge.signup_open? && File.mtime(ChallengeSignup.summary_file(@collection)) < 1.hour.ago)
        # either the file is missing, or signup is open and the last regeneration was more than an hour ago.

        # touch the file so we don't generate a second request
        summary_dir = ChallengeSignup.summary_dir
        FileUtils.mkdir_p(summary_dir) unless File.directory?(summary_dir)
        FileUtils.touch(ChallengeSignup.summary_file(@collection))

        # generate the page
        ChallengeSignup.generate_summary(@collection)
      end
    else
      # generate it on the fly
      @tag_type, @summary_tags = ChallengeSignup.generate_summary_tags(@collection)
      @generated_live = true
    end
  end

  def show
  end

  def new
    unless (@challenge_signup = ChallengeSignup.in_collection(@collection).by_user(current_user).first)
      flash[:error] = ts("Please submit a basic signup with the required fields first")
      redirect_to new_collection_signup_path(@collection) rescue redirect_to '/' and return
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
      flash[:notice] = 'Prompt was successfully updated.'
      redirect_to collection_signup_path(@collection, @challenge_signup)
    else
      render :action => :edit
    end
  end

  def destroy
    unless @challenge.signup_open || @collection.user_is_maintainer?(current_user)
      flash[:error] = ts("You cannot delete your prompt after signups are closed. Please contact a moderator for help.")
    else
      @prompt.destroy
      flash[:notice] = ts("Prompt was deleted.")
    end
    if @collection.user_is_maintainer?(current_user) && @collection.challenge_type == "PromptMeme"
      redirect_to collection_requests_path(@collection)
    elsif @collection.user_is_maintainer?(current_user)
      redirect_to collection_signups_path(@collection)
    else
      redirect_to @collection
    end
  end

end
