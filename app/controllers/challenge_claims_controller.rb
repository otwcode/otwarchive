class ChallengeClaimsController < ApplicationController

  before_filter :users_only
  before_filter :load_collection, :except => [:index]
  before_filter :collection_owners_only, :except => [:index, :show, :create, :destroy]
  before_filter :load_claim_from_id, :only => [:show, :destroy]

  before_filter :load_challenge, :except => [:index]
  
  before_filter :allowed_to_destroy, :only => [:destroy]


  # PERMISSIONS AND STATUS CHECKING

  def load_challenge
    if @collection
      @challenge = @collection.challenge
    elsif @challenge_claim
      @challenge = @challenge_claim.collection.challenge
    end
    no_challenge and return unless @challenge
  end

  def no_challenge
    flash[:error] = ts("What challenge did you want to work with?")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end

  def load_claim_from_id
    @challenge_claim = ChallengeClaim.find(params[:id])
    no_claim and return unless @challenge_claim
  end

  def no_claim
    flash[:error] = ts("What claim did you want to work on?")
    if @collection
      redirect_to collection_path(@collection) rescue redirect_to '/'
    else
      redirect_to user_path(@user) rescue redirect_to '/'
    end
    false
  end

  def load_user
    @user = User.find_by_login(params[:user_id]) if params[:user_id]
    no_user and return unless @user
  end
  
  def no_user
    flash[:error] = ts("What user were you trying to work with?")
    redirect_to "/" and return
    false
  end
  
  def owner_only
    unless @user == @challenge_claim.claiming_user
      flash[:error] = ts("You aren't the claimer of that prompt.")
      redirect_to "/" and return false
    end
  end      
  
  def allowed_to_destroy
    @challenge_claim.user_allowed_to_destroy?(current_user) || not_allowed(@collection)
  end
    
  
  # ACTIONS

  def index
    if !(@collection = Collection.find_by_name(params[:collection_id])).nil? && @collection.closed? && !@collection.user_is_maintainer?(current_user)
      flash[:notice] = ts("This challenge is currently closed to new posts.")
    end
    if params[:collection_id]
      return unless load_collection 
      @challenge = @collection.challenge if @collection
      @claims = ChallengeClaim.unposted_in_collection(@collection)
      if params[:for_user] || !@challenge.user_allowed_to_see_claims?(current_user)
        @claims = @claims.where(:claiming_user_id => current_user.id)
      end

      # sorting
      set_sort_order
      
      if params[:sort] == "claimer"
        @claims = @claims.order_by_offering_pseud(@sort_direction)
      else
        @claims = @claims.order(@sort_order)
      end
    elsif params[:user_id] && (@user = User.find_by_login(params[:user_id]))
      if current_user == @user
        @claims = @user.request_claims.order_by_date.unposted
				if params[:posted]
					@claims = @user.request_claims.order_by_date.posted
				end
        if params[:collection_id] && (@collection = Collection.find_by_name(params[:collection_id]))
          @claims = @claims.in_collection(@collection)         
        end
      else
        flash[:error] = ts("You aren't allowed to see that user's claims.")
        redirect_to '/' and return
      end
    end
    @claims = @claims.paginate :page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE
  end
  
  def show
    # this is here just as a failsafe, this path should not be used
    redirect_to collection_prompt_path(@collection, @challenge_claim.request_prompt)
  end
  
  def create
    # create a new claim
    claim = ChallengeClaim.new(params[:challenge_claim])
    if claim.save
      flash[:notice] = "New claim made."
    else
      flash[:error] = "We couldn't save the new claim."
    end
    redirect_to collection_claims_path(@collection, :for_user => true)
  end
  
  def destroy
    @claim = ChallengeClaim.find(params[:id])
    
    begin
      if @claim.claiming_user == current_user
        @usernotmod = "true"
      end
      @claim.destroy
      if @usernotmod == "true"
        flash[:notice] = ts("Your claim was deleted.")
      else
        flash[:notice] = ts("The claim was deleted.")
      end
    rescue
      flash[:error] = ts("We couldn't delete that right now, sorry! Please try again later.")
    end
    redirect_to collection_claims_path(@collection)
  end
  
end
