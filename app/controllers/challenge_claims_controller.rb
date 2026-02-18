class ChallengeClaimsController < ApplicationController
  before_action :users_only, except: [:index]
  before_action :users_or_privileged_collection_admin_only, only: [:index]
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
      @challenge = @challenge_claim.collection.challenge
    end
    no_challenge and return unless @challenge
  end

  def no_challenge
    flash[:error] = t("challenge_claims.no_challenge")
    begin
      redirect_to collection_path(@collection)
    rescue StandardError
      redirect_to "/"
    end
    false
  end

  def load_claim_from_id
    @challenge_claim = ChallengeClaim.find(params[:id])
    no_claim and return unless @challenge_claim
  end

  def no_claim
    flash[:error] = t("challenge_claims.no_claim")
    if @collection
      begin
        redirect_to collection_path(@collection)
      rescue StandardError
        redirect_to "/"
      end
    else
      begin
        redirect_to user_path(@user)
      rescue StandardError
        redirect_to "/"
      end
    end
    false
  end

  def load_user
    @user = User.find_by(login: params[:user_id]) if params[:user_id]
    no_user and return unless @user
  end

  def no_user
    flash[:error] = t("challenge_claims.no_user")
    redirect_to "/" and return
    false
  end

  def owner_only
    return if @user == @challenge_claim.claiming_user

    flash[:error] = t("challenge_claims.owner_only")
    redirect_to "/" and return false
  end

  def allowed_to_destroy
    @challenge_claim.user_allowed_to_destroy?(current_user) || not_allowed(@collection)
  end

  # ACTIONS

  def index
    flash[:notice] = t("challenge_claims.index.challenge_closed") if !(@collection = Collection.find_by(name: params[:collection_id])).nil? && @collection.closed? && !@collection.user_is_maintainer?(current_user) && !privileged_collection_admin?
    if params[:collection_id]
      return unless load_collection

      @challenge = @collection.challenge
      not_allowed(@collection) unless user_scoped? || @challenge.user_allowed_to_see_assignments?(current_user) || privileged_collection_admin?

      @claims = ChallengeClaim.unposted_in_collection(@collection)
      @claims = @claims.where(claiming_user_id: current_user.id) if user_scoped?

      # sorting
      set_sort_order

      @claims = if params[:sort] == "claimer"
                  @claims.order_by_offering_pseud(@sort_direction)
                else
                  @claims.order(@sort_order)
                end
    elsif params[:user_id] && (@user = User.find_by(login: params[:user_id]))
      if current_user == @user
        @claims = @user.request_claims.order_by_date.unposted
        @claims = @user.request_claims.order_by_date.posted if params[:posted]
        @claims = @claims.in_collection(@collection) if params[:collection_id] && (@collection = Collection.find_by(name: params[:collection_id]))
      else
        flash[:error] = t("challenge_claims.index.access_denied_user_claims")
        redirect_to "/" and return
      end
    end
    @claims = @claims.paginate page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE
  end

  def show
    # this is here just as a failsafe, this path should not be used
    redirect_to collection_prompt_path(@collection, @challenge_claim.request_prompt)
  end

  def create
    # create a new claim
    prompt = @collection.prompts.find(params[:prompt_id])
    claim = prompt.request_claims.build(claiming_user: current_user)
    if claim.save
      flash[:notice] = "New claim made."
    else
      flash[:error] = "We couldn't save the new claim."
    end
    redirect_to collection_claims_path(@collection, for_user: true)
  end

  def destroy
    redirect_path = collection_claims_path(@collection)
    flash[:notice] = t("challenge_claims.destroy.claim_deleted")

    if @challenge_claim.claiming_user == current_user
      redirect_path = collection_claims_path(@collection, for_user: true)
      flash[:notice] = t("challenge_claims.destroy.your_claim_deleted")
    end

    begin
      @challenge_claim.destroy
    rescue StandardError
      flash.delete(:notice)
      flash[:error] = t("challenge_claims.destroy.delete_failed")
    end
    redirect_to redirect_path
  end

  private

  def user_scoped?
    params[:for_user].to_s.casecmp?("true")
  end
end
