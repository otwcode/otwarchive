class PotentialMatchesController < ApplicationController

  before_filter :users_only
  before_filter :load_collection
  before_filter :collection_maintainers_only
  before_filter :load_challenge
  before_filter :check_assignments_not_sent
  before_filter :check_signup_closed, :only => [:generate]
  before_filter :load_potential_match_from_id, :only => [:show]


  def load_challenge
    @challenge = @collection.challenge
    no_challenge and return unless @challenge
  end

  def no_challenge
    flash[:error] = t('challenges.no_challenge', :default => "What challenge did you want to sign up for?")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end

  def load_potential_match_from_id
    @potential_match = PotentialMatch.find(params[:id])
    no_potential_match and return unless @potential_match
  end

  def no_assignment
    flash[:error] = t('potential_match.no_match', :default => "What potential match did you want to work on?")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end
  
  def check_signup_closed
    signup_open and return unless !@challenge.signup_open 
  end

  def signup_open
    flash[:error] = t('potential_match.signup_open', :default => "Signup is still open, you cannot determine potential matches now.")
    redirect_to @collection rescue redirect_to '/'
    false
  end
  
  def check_assignments_not_sent
    assignments_sent and return unless @challenge.assignments_sent_at.nil? 
  end

  def assignments_sent
    flash[:error] = t('challenge_assignments.assignments_sent', :default => "Assignments have already been sent! If necessary, you can purge them.")
    redirect_to collection_assignments_path(@collection) rescue redirect_to '/'
    false
  end

  def index
    @settings = @collection.challenge.potential_match_settings
    
    if PotentialMatch.in_progress?(@collection)
      @in_progress = true
      @current_position = PotentialMatch.position(@collection)
      @progress = PotentialMatch.progress(@collection)
    else
      # we have potential_matches and assignments      
      
      # index the potential matches by request_signup
      @assignments_with_no_offer = @collection.assignments.with_request.with_no_offer.sort
      @assignments_with_no_request = @collection.assignments.with_offer.with_no_request.sort

      @assignments_with_no_potential_requests = @assignments_with_no_request.select {|assignment| assignment.offer_signup.offer_potential_matches.empty?}
      
      unless (@assignments_with_no_potential_requests.size > 0)
        @assignments_with_request_and_offer = @collection.assignments.with_request.with_offer.order_by_requesting_pseud.paginate :page => params[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE

        @assignments_with_no_assigned_requests = @collection.assignments.with_no_request.select {|assignment| assignment.pinch_request_signup.blank?}
      end
    end
  end

  # Generate potential matches
  def generate
    if PotentialMatch.in_progress?(@collection)
      flash[:error] = ts("Potential matches are already being generated for this collection!")
    else
      # delete all existing assignments and potential matches for this collection
      ChallengeAssignment.clear!(@collection)
      PotentialMatch.clear!(@collection)
      
      flash[:notice] = ts("Beginning generation of potential matches. This may take some time, especially if your challenge is large.")
      PotentialMatch.set_up_generating(@collection)
      PotentialMatch.generate(@collection)
    end

    # redirect to index
    redirect_to collection_potential_matches_path(@collection)
  end
  
  def cancel_generate
    if !PotentialMatch.in_progress?(@collection)
      flash[:error] = ts("Potential matches are not currently being generated for this challenge.")
    elsif PotentialMatch.canceled?(@collection)
      flash[:error] = ts("Potential match generation has already been canceled, please refresh again shortly.")
    else
      PotentialMatch.cancel_generation(@collection)
      flash[:notice] = ts("Potential match generation cancellation requested. This may take a while, please refresh shortly.")
    end
    
    redirect_to collection_potential_matches_path(@collection)
  end
  
  def show
  end

  def generate_progress
    if PotentialMatch.in_progress?(@collection)
      @current_position = PotentialMatch.position(@collection)
      @progress = PotentialMatch.progress(@collection)
    end
  end

end
