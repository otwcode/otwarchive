class Challenge::PromptMemeController < ChallengesController
  
  before_filter :users_only
  before_filter :load_collection
  before_filter :load_challenge, :except => [:new, :create]
  before_filter :collection_owners_only, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :set_time_zone, :only => [:create, :edit, :update]

  # ACTIONS

  # we use this to make the times get set in the moderator's specified timezone
  def set_time_zone
    if params[:prompt_meme] && params[:prompt_meme][:time_zone]
      Time.zone = params[:prompt_meme][:time_zone]
    elsif @challenge && @challenge.time_zone
      Time.zone = @challenge.time_zone
    end
  end

  def show
  end

  def new
    if (@collection.challenge)
      flash[:notice] = t('prompt_meme.already_challenge', :default => "There is already a challenge set up for this collection.")
      redirect_to edit_collection_prompt_meme_path(@collection)
    else
      @challenge = PromptMeme.new
    end
  end

  def edit
  end

  def create
    @challenge = PromptMeme.new(params[:prompt_meme])
    if @challenge.save
      @collection.challenge = @challenge
      @collection.save
      flash[:notice] = 'Challenge was successfully created.'
      
      # see if we initialized the tag set
      if initializing_tag_sets?
        flash[:notice] += ts(' The tag list is being initialized. Please wait a short while and then check your challenge settings to customize the results.')
      end
      redirect_to @collection
    else
      render :action => :new
    end
  end

  def update
    if @challenge.update_attributes(params[:prompt_meme])
      flash[:notice] = 'Challenge was successfully updated.'
      
      # expire the cache on the signup form
      expire_fragment(:controller => 'challenge_signups', :action => 'new')
      
      # see if we initialized the tag set
      if initializing_tag_sets?
        # we were asked to initialize the tag set
        flash[:notice] += ts(' The tag list is being initialized. Please wait a short while and then check your challenge settings to customize the results.')
      end
      redirect_to @collection
    else
      render :action => :edit
    end
  end

  def destroy
    @challenge.destroy
    flash[:notice] = 'Challenge settings were deleted.'
    redirect_to @collection
  end
  
  private
  def initializing_tag_sets?
    # uuughly :P but check params to see if we're initializing 
    !params[:prompt_meme][:request_restriction_attributes].keys.
      select {|k| k=~ /init_(less|greater)/}.
      select {|k| params[:prompt_meme][:request_restriction_attributes][k] == "1"}.
      empty?
  end

end
