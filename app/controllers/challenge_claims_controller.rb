class ChallengeClaimsController < ApplicationController

  before_filter :users_only
  before_filter :load_collection, :except => [:index]
  before_filter :collection_owners_only, :except => [:index, :show, :create]
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
    @challenge_claim.user_allowed_to_destroy?(current_user) || not_allowed
  end
  
  def not_allowed
    flash[:error] = ts("Sorry, you're not allowed to do that.")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end
  
  
  # ACTIONS

  def index
    if params[:user_id] && (@user = User.find_by_login(params[:user_id]))
      if current_user == @user
        if params[:collection_id] && (@collection = Collection.find_by_name(params[:collection_id]))
          @challenge_claims = @user.request_claims.in_collection(@collection).unposted         
        else
          @challenge_claims = @user.request_claims.unposted
        end
      else
        flash[:error] = t('challenge_claims.not_allowed_to_see_other', :default => "You aren't allowed to see that user's claims.")
        redirect_to '/' and return
      end
    else
      # do error-checking for the collection case
      return unless load_collection 
      @challenge = @collection.challenge if @collection
      
      
      @unposted_claims = @collection.claims.unposted.order_by_requesting_pseud.paginate :page => params[:page], :per_page => 20
      @posted_claims = @collection.claims.posted.order_by_requesting_pseud.paginate :page => params[:page], :per_page => 20
      
      if !@challenge.user_allowed_to_see_claims?(current_user)
        @user = current_user
        @challenge_claims = @user.request_claims.in_collection(@collection).unposted
      end

    end
  end
  
  def show
    unless @challenge.user_allowed_to_see_claims?(current_user) || @challenge_claim.claiming_user == current_user
      flash[:error] = "You aren't allowed to see that claim!"
      redirect_to "/" and return
    end
  end
  
  def create
    # create a new claim
    claim = ChallengeClaim.new(params[:challenge_claim])
    if claim.save
      flash[:notice] = "New claim made."
    else
      flash[:error] = "We couldn't save the new claim."
    end
    redirect_to collection_claims_path(@collection)
  end
  
  def destroy
    flash[:notice] = "One day you will be able to cancel a claim."
    redirect_to collection_claims_path(@collection)
  end
  
end
