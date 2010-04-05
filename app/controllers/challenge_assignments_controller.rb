class ChallengeAssignmentsController < ApplicationController

  before_filter :users_only
  before_filter :load_collection, :except => [:index, :default]
  before_filter :collection_owners_only, :except => [:index, :show, :default]
  before_filter :load_challenge, :except => [:index, :default]
  before_filter :load_user, :only => [:default]
  before_filter :load_assignment_from_id, :only => [:show, :default, :undefault]
  before_filter :owner_only, :only => [:default]
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
    flash[:error] = t("challenge_assignments.no_user", :default => "What user were you trying to work with?")
    redirect_to "/" and return
    false
  end
  
  def owner_only
    unless @user == @challenge_assignment.offering_pseud.user
      flash[:error] = t("challenge_assignments.not_owner", :default => "You aren't the owner of that assignment.")
      redirect_to "/" and return false
    end
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
        @challenge_assignments = @user.offer_assignments.open + @user.pinch_hit_assignments.open
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
      
      if !@challenge.user_allowed_to_see_assignments?(current_user)
        @challenge_assignments = @collection.assignments.by_offering_user(current_user)
        @user = current_user
      end
    end
  end
  
  def show
    unless @challenge.user_allowed_to_see_assignments?(current_user) || @challenge_assignment.offer_pseud.user == current_user
      flash[:error] = "You aren't allowed to see that assignment!"
      redirect_to "/" and return
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
      if ArchiveConfig.NO_DELAYS
        ChallengeAssignment.send_out!(@collection)
      else
        ChallengeAssignment.send_later send_out!, @collection
      end
      flash[:notice] = "Assignments are now being sent out."
      redirect_to collection_assignments_path(@collection)
    else
      ChallengeAssignment.update(params[:challenge_assignments].keys, params[:challenge_assignments].values)
      ChallengeAssignment.update_placeholder_assignments!(@collection)
      flash[:notice] = "Assignments updated"
      redirect_to collection_potential_matches_path(@collection)
    end    
  end
  
  def create
    # create a new (presumably pinch hit) assignment
    assignment = ChallengeAssignment.new(params[:challenge_assignment])
    if assignment.save
      flash[:notice] = "New assignment created."
    else
      flash[:error] = "We couldn't save the new assignment."
    end
    if params[:assignment_to_cover] && (@old_assignment = ChallengeAssignment.find(params[:assignment_to_cover]))
      @old_assignment.covered_at = Time.now
      @old_assignment.save
    end
    redirect_to collection_assignments_path(@collection)
  end
  
  def mark_defaulted
    # update all the assignments
    ChallengeAssignment.update(params[:challenge_assignments].keys, params[:challenge_assignments].values)
    flash[:notice] = "Defaulters updated."
    redirect_to collection_assignments_path(@collection)
  end
  
  def default
    @challenge_assignment.defaulted_at = Time.now
    @challenge_assignment.save
    @challenge_assignment.collection.notify_maintainers("Challenge default by #{@challenge_assignment.offer_byline}", 
        "Signed-up participant #{@challenge_assignment.offer_byline} has defaulted on their assignment for #{@challenge_assignment.request_byline}. " + 
        "You may want to assign a pinch hitter on the collection assignments page: #{collection_assignments_url(@challenge_assignment.collection)}")
    flash[:notice] = "We have notified the collection maintainers that you had to default on your assignment."
    redirect_to user_assignments_path(@user)
  end
  
  def undefault
    @challenge_assignment.defaulted_at = nil
    @challenge_assignment.save
    flash[:notice] = "Assignment marked as not-defaulted."
    redirect_to collection_assignments_path(@collection)
  end
  
end
