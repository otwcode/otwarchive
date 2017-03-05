class ChallengeClaimsController < ApplicationController
  before_filter :users_only
  before_filter :load_collection, except: [:index]
  before_filter :collection_owners_only, except: [:index, :show, :create, :destroy]
  before_filter :load_claim_from_id, only: [:show, :destroy]
  before_filter :load_challenge, except: [:index]
  before_filter :allowed_to_destroy, only: [:destroy]

  # PERMISSIONS AND STATUS CHECKING

  def load_challenge
    if @collection
      @challenge = @collection.challenge
    elsif @challenge_claim
      # What we want is the ruby &. operator
      @challenge = @challenge_claim.collection.challenge if @challenge_claim.collection
    end
    no_challenge && return unless @challenge
  end

  def no_challenge
    flash[:error] = ts("What challenge did you want to work with?")
    redirect_to collection_path(@collection) rescue redirect_to root_path
    false
  end

  def load_claim_from_id
    @challenge_claim = ChallengeClaim.find_by_id(params[:id])
    no_claim && return unless @challenge_claim
  end

  def no_claim
    flash[:error] = ts("What claim did you want to work on?")
    if @collection
      redirect_to collection_path(@collection) rescue redirect_to root_path
    else
      redirect_to user_path(@user) rescue redirect_to root_path
    end
    false
  end

  def allowed_to_destroy
    @challenge_claim.user_allowed_to_destroy?(current_user) || not_allowed(@collection)
  end

  # ACTIONS

  def index
    flash[:notice] = ts("This challenge is currently closed to new posts.") if !(@collection = Collection.find_by_name(params[:collection_id])).nil? && @collection.closed? && !@collection.user_is_maintainer?(current_user)
    if params[:collection_id]
      return unless load_collection
      @challenge = @collection.challenge if @collection
      @claims = ChallengeClaim.unposted_in_collection(@collection)
      @claims = @claims.where(claiming_user_id: current_user.id) if params[:for_user] || !@challenge.user_allowed_to_see_claims?(current_user)
      # sorting
      set_sort_order
      @claims = params[:sort] == "claimer" ? @claims.order_by_offering_pseud(@sort_direction) : @claims.order(@sort_order)
    elsif params[:user_id]
      @user = User.find_by_login(params[:user_id])
      if current_user == @user
        @claims = @user.request_claims.order_by_date.unposted
        @claims = @user.request_claims.order_by_date.posted if params[:posted]
        @claims = @claims.in_collection(@collection) if params[:collection_id] && (@collection = Collection.find_by_name(params[:collection_id]))
      else
        flash[:error] = ts("You aren't allowed to see that user's claims.")
        redirect_to root_path
        return
      end
    end
    @claims = @claims.paginate page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE
  end

  def show
    # this is here just as a failsafe, this path should not be used
    redirect_to collection_prompt_path(@collection, @challenge_claim.request_prompt) rescue redirect_to root_path
  end

  def create
    # create a new claim
    claim = ChallengeClaim.new(params[:challenge_claim])
    if claim.save
      flash[:notice] = ts("New claim made.")
    else
      flash[:error] = ts("We couldn't save the new claim.")
    end
    redirect_to collection_claims_path(@collection, for_user: true)
  end

  def destroy
    @claim = ChallengeClaim.find(params[:id])
    begin
      @claim.destroy
      flash[:notice] = @claim.claiming_user == current_user ? ts("Your claim was deleted.") : ts("The claim was deleted.")
    rescue
      flash[:error] = ts("We couldn't delete that right now, sorry! Please try again later.")
    end
    redirect_to collection_claims_path(@collection)
  end
end
