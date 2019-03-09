class ChallengeClaimsController < ApplicationController

  before_action :users_only
  before_action :load_collection, except: [:index]
  before_action :collection_owners_only, except: [:index, :show, :create, :destroy]
  before_action :load_claim_from_id, only: [:show, :destroy]
  before_action :load_challenge, except: [:index]
  before_action :allowed_to_destroy, only: [:destroy]


  # PERMISSIONS AND STATUS CHECKING

  def load_challenge
    if @collection
      @challenge = @collection.challenge
    elsif @challenge_claim
      @challenge = @challenge_claim&.collection&.challenge
    end
    return unless @challenge
    no_challenge
  end

  def no_challenge
    flash[:error] = ts("What challenge did you want to work with?")
    redirect_to collection_path(@collection) rescue redirect_to root_path
    false
  end

  def load_claim_from_id
    @challenge_claim = ChallengeClaim.find_by_id(params[:id])
    return unless @challenge_claim.nil?
    no_claim
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
    if !(@collection = Collection.find_by(name: params[:collection_id])).nil? && @collection.closed? && !@collection.user_is_maintainer?(current_user)
      flash[:notice] = ts("This challenge is currently closed to new posts.")
    end
    if params[:collection_id]
      return unless load_collection
      @challenge = @collection.challenge if @collection
      @claims = ChallengeClaim.unposted_in_collection(@collection)

      @claims = @claims.where(claiming_user_id: current_user.id) if params[:for_user] || !@challenge.user_allowed_to_see_claims?(current_user)


      # sorting
      set_sort_order
      @claims = params[:sort] == "claimer" ? @claims.order_by_offering_pseud(@sort_direction) : @claims.order(@sort_order)
    elsif params[:user_id].present && (@user = User.find_by(login: params[:user_id]))
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
    claim = ChallengeClaim.new(challenge_claim_params)
    if claim.save
      flash[:notice] = "New claim made."
    else
      flash[:error] = "We couldn't save the new claim."
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

  private

  def challenge_claim_params
    params.require(:challenge_claim).permit(
      :collection_id, :request_signup_id, :request_prompt_id, :claiming_user_id
    )
  end
end
