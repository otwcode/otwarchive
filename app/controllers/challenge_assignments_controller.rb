class ChallengeAssignmentsController < ApplicationController

  before_filter :users_only
  before_filter :load_collection, :except => [:index]
  before_filter :collection_owners_only, :except => [:index]
  before_filter :load_challenge, :except => [:index]
  before_filter :load_assignment_from_id, :only => [:show, :edit, :update, :destroy]
  before_filter :allowed_to_destroy, :only => [:destroy]
  before_filter :check_signup_closed, :only => [:new, :create, :edit, :update]


  def load_challenge
    @challenge = @collection.challenge
    no_challenge and return unless @challenge
  end

  def no_challenge
    flash[:error] = t('challenges.no_challenge', :default => "What challenge did you want to sign up for?")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end

  def load_assignment_from_id
    @challenge_assignment = ChallengeAssignment.find(params[:id])
    no_assignment and return unless @challenge_assignment
  end

  def no_assignment
    flash[:error] = t('challenge_assignments.no_assignment', :default => "What assignment did you want to work on?")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end
  
  def check_signup_closed
    signup_open and return unless !@challenge.signup_open 
  end

  def signup_open
    flash[:error] = t('challenge_assignments.signup_open', :default => "Signup is currently open, you cannot make assignments now.")
    redirect_to @collection rescue redirect_to '/'
    false
  end

  def allowed_to_destroy
    @challenge_assignment.user_allowed_to_destroy?(current_user) || not_allowed
  end
  
  def not_allowed
    flash[:error] = t('challenge_signups.not_allowed', :default => "Sorry, you're not allowed to do that.")
    redirect_to collection_path(@collection) rescue redirect_to '/'
    false
  end

  def index
    if params[:user_id] && (@user = User.find_by_login(params[:user_id]))
      if current_user == @user
        @challenge_assignments = @user.challenge_assignments + @user.pinch_hit_assignments
      else
        flash[:error] = t('challenge_assignments.not_allowed_to_see_other', :default => "You aren't allowed to see that user's assignments.")
        redirect_to '/' and return
      end
    else
      load_collection 
      load_challenge if @collection
      unless @challenge
        no_challenge
        redirect_to '/' and return
      end
      
      if @challenge.user_allowed_to_see_assignments?(current_user)
        @challenge_assignments = @collection.assignments
      else
        @challenge_assignments = @collection.assignments.by_offering_user(current_user)
      end
    end
  end
  
  def generate
    # regenerate assignments using the current potential matches
    ChallengeAssignment.generate!(@collection)
    redirect_to collection_potential_matches_path(@collection)
  end
  
  def set
    # update all the assignments
    # see http://asciicasts.com/episodes/198-edit-multiple-individually
    if params["send"]
      # sending these assignments out!
      # ChallengeAssignment.send_later send_out!, @collection
      ChallengeAssignment.send_out!(@collection)
      flash[:notice] = "Assignments are now being sent out."
      redirect_to collection_assignments_path(@collection)
    else
      ChallengeAssignment.update(params[:challenge_assignments].keys, params[:challenge_assignments].values)
      ChallengeAssignment.update_placeholder_assignments!(@collection)
      flash[:notice] = "Assignments updated"
      redirect_to collection_potential_matches_path(@collection)
    end    
  end
  
end
