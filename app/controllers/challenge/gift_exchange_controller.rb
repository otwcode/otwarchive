class Challenge::GiftExchangeController < ChallengesController
  
  before_filter :users_only
  before_filter :load_collection
  before_filter :load_challenge, :except => [:new, :create]
  before_filter :collection_owners_only, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :set_time_zone, :only => [:create, :edit, :update]

  # ACTIONS

  # we use this to make the times get set in the moderator's specified timezone
  def set_time_zone
    if params[:gift_exchange] && params[:gift_exchange][:time_zone]
      Time.zone = params[:gift_exchange][:time_zone]
    elsif @challenge && @challenge.time_zone
      Time.zone = @challenge.time_zone
    end
  end

  def show
  end

  def new
    if (@collection.challenge)
      flash[:notice] = ts("There is already a challenge set up for this collection.")
      # TODO this will break if the challenge isn't a gift exchange
      redirect_to edit_collection_gift_exchange_path(@collection)
    else
      @challenge = GiftExchange.new
    end
  end

  def edit
  end

  def create
    @challenge = GiftExchange.new(params[:gift_exchange])
    if @challenge.save
      @collection.challenge = @challenge
      @collection.save
      flash[:notice] = ts('Challenge was successfully created.')      
      redirect_to collection_profile_path(@collection)
    else
      render :action => :new
    end
  end

  def update
    if @challenge.update_attributes(params[:gift_exchange])
      flash[:notice] = ts('Challenge was successfully updated.')
      
      # expire the cache on the signup form
      expire_fragment(:controller => 'challenge_signups', :action => 'new')
      
      # see if we initialized the tag set
      redirect_to collection_profile_path(@collection)
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
    !params[:gift_exchange][:offer_restriction_attributes].keys.
      select {|k| k=~ /init_(less|greater)/}.
      select {|k| params[:gift_exchange][:offer_restriction_attributes][k] == "1"}.
      empty?
  end


end
