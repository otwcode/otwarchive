class PotentialMatchesController < ApplicationController
  before_action :users_only, except: [:index, :show]
  before_action :users_or_privileged_collection_admin_only, only: [:index, :show]
  before_action :load_collection
  before_action :collection_maintainers_or_privileged_admins_only, only: [:index, :show]
  before_action :collection_maintainers_only, except: [:index, :show]
  before_action :load_challenge
  before_action :check_assignments_not_sent
  before_action :check_signup_closed, only: [:generate]
  before_action :load_potential_match_from_id, only: [:show]

  def load_challenge
    @challenge = @collection.challenge
    no_challenge and return unless @challenge
  end

  def no_challenge
    flash[:error] = t("potential_matches.no_challenge")
    begin
      redirect_to collection_path(@collection)
    rescue StandardError
      redirect_to "/"
    end
    false
  end

  def load_potential_match_from_id
    @potential_match = PotentialMatch.find(params[:id])
    no_potential_match and return unless @potential_match
  end

  def no_assignment
    flash[:error] = t("potential_matches.no_assignment")
    begin
      redirect_to collection_path(@collection)
    rescue StandardError
      redirect_to "/"
    end
    false
  end

  def check_signup_closed
    signup_open and return if @challenge.signup_open
  end

  def signup_open
    flash[:error] = t("potential_matches.signup_open")
    begin
      redirect_to @collection
    rescue StandardError
      redirect_to "/"
    end
    false
  end

  def check_assignments_not_sent
    assignments_sent and return unless @challenge.assignments_sent_at.nil?
  end

  def assignments_sent
    flash[:error] = t("potential_matches.assignments_sent")
    begin
      redirect_to collection_assignments_path(@collection)
    rescue StandardError
      redirect_to "/"
    end
    false
  end

  def index
    @settings = @collection.challenge.potential_match_settings

    if (invalid_ids = PotentialMatch.invalid_signups_for(@collection)).present?
      # there are invalid signups
      @invalid_signups = ChallengeSignup.where(id: invalid_ids)
    elsif PotentialMatch.in_progress?(@collection)
      # we're generating
      @in_progress = true
      @progress = PotentialMatch.progress(@collection)
    elsif ChallengeAssignment.in_progress?(@collection)
      @assignment_in_progress = true
    elsif @collection.potential_matches.count.positive? && @collection.assignments.count.zero?
      flash[:error] = t("potential_matches.index.matching_error")
    elsif @collection.potential_matches.count.positive?
      # we have potential_matches and assignments

      ### find assignments with no potential recipients
      # first get signups with no offer potential matches
      no_opms = ChallengeSignup.in_collection(@collection).no_potential_offers.pluck(:id)
      @assignments_with_no_potential_recipients = @collection.assignments.where(offer_signup_id: no_opms)

      ### find assignments with no potential giver
      # first get signups with no request potential matches
      no_rpms = ChallengeSignup.in_collection(@collection).no_potential_requests.pluck(:id)
      @assignments_with_no_potential_givers = @collection.assignments.where(request_signup_id: no_rpms)

      # list the assignments by requester
      @assignments = if params[:no_giver]
                       @collection.assignments.with_request.with_no_offer.order_by_requesting_pseud
                     elsif params[:no_recipient]
                       # ordering causes this to hang on large challenge due to
                       # left join required to get offering pseuds
                       @collection.assignments.with_offer.with_no_request # .order_by_offering_pseud
                     elsif params[:dup_giver]
                       ChallengeAssignment.duplicate_givers(@collection).order_by_offering_pseud
                     elsif params[:dup_recipient]
                       ChallengeAssignment.duplicate_recipients(@collection).order_by_requesting_pseud
                     else
                       @collection.assignments.with_request.with_offer.order_by_requesting_pseud
                     end
      @assignments = @assignments.paginate page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE
    end
  end

  # Generate potential matches
  def generate
    if PotentialMatch.in_progress?(@collection)
      flash[:error] = t("potential_matches.generate.already_in_progress")
    else
      # delete all existing assignments and potential matches for this collection
      ChallengeAssignment.clear!(@collection)
      PotentialMatch.clear!(@collection)

      flash[:notice] = t("potential_matches.generate.started")
      PotentialMatch.set_up_generating(@collection)
      PotentialMatch.generate(@collection)
    end

    # redirect to index
    redirect_to collection_potential_matches_path(@collection)
  end

  # Regenerate matches for one signup
  def regenerate_for_signup
    if params[:signup_id].blank? || (@signup = ChallengeSignup.where(id: params[:signup_id]).first).nil?
      flash[:error] = t("potential_matches.regenerate_for_signup.no_signup")
    else
      PotentialMatch.regenerate_for_signup(@signup)
      flash[:notice] = t("potential_matches.regenerate_for_signup.started", pseud: @signup.pseud.byline)
    end
    # redirect to index
    redirect_to collection_potential_matches_path(@collection)
  end

  def cancel_generate
    if !PotentialMatch.in_progress?(@collection)
      flash[:error] = t("potential_matches.cancel_generate.not_in_progress")
    elsif PotentialMatch.canceled?(@collection)
      flash[:error] = t("potential_matches.cancel_generate.already_canceled")
    else
      PotentialMatch.cancel_generation(@collection)
      flash[:notice] = t("potential_matches.cancel_generate.requested")
    end

    redirect_to collection_potential_matches_path(@collection)
  end

  def show
  end
end
