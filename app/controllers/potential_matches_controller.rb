class PotentialMatchesController < ApplicationController

  before_filter :users_only
  before_filter :load_collection
  before_filter :collection_maintainers_only
  before_filter :load_challenge
  before_filter :load_potential_match_from_id, :only => [:show]
  before_filter :check_signup_closed, :only => [:generate]


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
  
  def not_allowed
    flash[:error] = t('potential_match.not_allowed', :default => "Sorry, you're not allowed to do that.")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end

  def index
    if PotentialMatch.in_progress?(@collection)
      @in_progress = true
      @current_position = PotentialMatch.position(@collection)
    else
      # we have potential_matches and assignments
      # index the potential matches by request_signup
      @potential_matches = {}
      @collection.potential_matches.each do |match| 
        @potential_matches[match.request_signup.id] ||= []
        @potential_matches[match.request_signup.id] << match
      end
      @assignments = @collection.assignments.sort
    end
  end

  # Generate potential matches
  def generate
    if PotentialMatch.in_progress?(@collection)
      flash[:error] = t("potential_matches.generating_already", :default => "Potential matches are already being generated for this collection!")
    else
      # delete all existing assignments and potential matches for this collection
      ChallengeAssignment.clear!(@collection)
      PotentialMatch.clear!(@collection)
      
      flash[:notice] = t("potential_matches.generating_beginning", :default => "Beginning generation of potential matches. This may take some time, especially if your challenge is large.")
      if ArchiveConfig.NO_DELAYS
        PotentialMatch.generate!(@collection)
      else
        PotentialMatch.send_later :generate!, @collection
      end
    end

    # redirect to index
    redirect_to collection_potential_matches_path(@collection)
  end
  
  def show
  end

end
