class Challenge::PromptMemeController < ChallengesController

  before_filter :users_only
  before_filter :load_collection
  before_filter :load_challenge, :except => [:new, :create]
  before_filter :collection_owners_only, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :set_time_zone, :only => [:create, :edit, :update]

  # ACTIONS

  # we use this to make the times get set in the moderator's specified timezone
  def set_time_zone
    if params[:prompt_meme] && prompt_meme_params[:time_zone]
      Time.zone = prompt_meme_params[:time_zone]
    elsif @challenge && @challenge.time_zone
      Time.zone = @challenge.time_zone
    end
  end

  # is actually a blank page - should it be redirected to collection profile?
  def show
  end

  # The new form for prompt memes is actually the challenge settings page because challenges are always created in the context of a collection.
  def new
    if (@collection.challenge)
      flash[:notice] = ts("There is already a challenge set up for this collection.")
      redirect_to edit_collection_prompt_meme_path(@collection)
    else
      @challenge = PromptMeme.new
    end
  end

  def edit
  end

  def create
    @challenge = PromptMeme.new(prompt_meme_params)
    if @challenge.save
      @collection.challenge = @challenge
      @collection.save
      flash[:notice] = ts('Challenge was successfully created.')

      # see if we initialized the tag set
      if initializing_tag_sets?
        flash[:notice] += ts(' The tag list is being initialized. Please wait a short while and then check your challenge settings to customize the results.')
      end
      redirect_to collection_profile_path(@collection)
    else
      render :action => :new
    end
  end

  def update
    if @challenge.update_attributes(prompt_meme_params)
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

  # creating automatic list of most popular or least popular tags on the archive
  def initializing_tag_sets?
    # uuughly :P but check params to see if we're initializing
    !params[:prompt_meme][:request_restriction_attributes].keys.
      select {|k| k=~ /init_(less|greater)/}.
      select {|k| params[:prompt_meme][:request_restriction_attributes][k] == "1"}.
      empty?
  end

  def prompt_meme_params
    params.require(:prompt_meme).permit(
      :signup_open, :time_zone, :signups_open_at_string, :signups_close_at_string,
      :assignments_due_at_string, :anonymous, :requests_num_required, :requests_num_allowed,
      :signup_instructions_general, :signup_instructions_requests, :request_url_label,
      :request_description_label, :works_reveal_at_string, :authors_reveal_at_string,
      request_restriction_attributes: [ :id, :optional_tags_allowed, :title_required,
        :title_allowed, :description_required, :description_allowed, :url_required,
        :url_allowed, :fandom_num_required, :fandom_num_allowed, :require_unique_fandom,
        :character_num_required, :character_num_allowed, :category_num_required,
        :category_num_allowed, :require_unique_category, :require_unique_character,
        :relationship_num_required, :relationship_num_allowed, :require_unique_relationship,
        :rating_num_required, :rating_num_allowed, :require_unique_rating,
        :freeform_num_required, :freeform_num_allowed, :require_unique_freeform,
        :warning_num_required, :warning_num_allowed, :require_unique_warning,
        :tag_sets_to_remove, :tag_sets_to_add, :character_restrict_to_fandom,
        :character_restrict_to_tag_set, :relationship_restrict_to_fandom,
        :relationship_restrict_to_tag_set, tag_sets_to_remove: []
      ]
    )
  end

end
