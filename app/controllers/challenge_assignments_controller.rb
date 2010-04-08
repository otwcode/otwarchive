class ChallengeAssignmentsController < ApplicationController

  before_filter :users_only
  before_filter :load_collection, :except => [:index, :default]
  before_filter :collection_owners_only, :except => [:index, :show, :default]
  before_filter :load_assignment_from_id, :only => [:show, :default, :undefault, :ignore_default]

  before_filter :load_challenge, :except => [:index]
  before_filter :check_signup_closed, :except => [:index]
  before_filter :check_assignments_not_sent, :only => [:generate, :set, :send_out]
  before_filter :check_assignments_sent, :only => [:create, :default, :undefault, :mark_defaulted, :ignore_default, :purge]

  before_filter :load_user, :only => [:default]
  before_filter :owner_only, :only => [:default]


  # PERMISSIONS AND STATUS CHECKING

  def load_challenge
    if @collection
      @challenge = @collection.challenge
    elsif @challenge_assignment
      @challenge = @challenge_assignment.collection.challenge
    end
    no_challenge and return unless @challenge
  end

  def no_challenge
    flash[:error] = t('challenge_assignments.no_challenge', :default => "What challenge did you want to work with?")
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

  def check_assignments_not_sent
    assignments_sent and return unless @challenge.assignments_sent_at.nil? 
  end

  def assignments_sent
    flash[:error] = t('challenge_assignments.assignments_sent', :default => "Assignments have already been sent! If necessary, you can purge them.")
    redirect_to collection_assignments_path(@collection) rescue redirect_to '/'
    false
  end

  def check_assignments_sent
    assignments_not_sent and return unless @challenge.assignments_sent_at 
  end

  def assignments_not_sent
    flash[:error] = t('challenge_assignments.assignments_not_sent', :default => "Assignments have not been sent! You might want matching instead.")
    redirect_to collection_path(@collection) rescue redirect_to '/'
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
  
  
  # ACTIONS

  def index
    if params[:user_id] && (@user = User.find_by_login(params[:user_id]))
      if current_user == @user
        if params[:collection_id] && (@collection = Collection.find_by_name(params[:collection_id]))
          @challenge_assignments = @user.offer_assignments.in_collection(@collection).open + @user.pinch_hit_assignments.in_collection(@collection).open          
        else
          @challenge_assignments = @user.offer_assignments.open + @user.pinch_hit_assignments.open
        end
      else
        flash[:error] = t('challenge_assignments.not_allowed_to_see_other', :default => "You aren't allowed to see that user's assignments.")
        redirect_to '/' and return
      end
    else
      # do error-checking for the collection case
      return unless load_collection 
      return unless load_challenge
      return unless check_signup_closed
      return unless check_assignments_sent
      
      if !@challenge.user_allowed_to_see_assignments?(current_user)
        @user = current_user
        @challenge_assignments = @user.offer_assignments.in_collection(@collection).open + @user.pinch_hit_assignments.in_collection(@collection).open
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
  
  def send_out
    # sending the current assignments out
    @challenge.assignments_sent_at = Time.now
    @challenge.save
    
    # purge the potential matches! we don't want bazillions of them in our db
    PotentialMatch.clear!(@collection)
    
    if ArchiveConfig.NO_DELAYS
      ChallengeAssignment.send_out!(@collection)
    else
      ChallengeAssignment.send_later :send_out!, @collection
    end
    flash[:notice] = "Assignments are now being sent out."
    redirect_to collection_assignments_path(@collection)
  end
  
  def set
    # update all the assignments
    # see http://asciicasts.com/episodes/198-edit-multiple-individually
    ChallengeAssignment.update(params[:challenge_assignments].keys, params[:challenge_assignments].values)
    ChallengeAssignment.update_placeholder_assignments!(@collection)
    flash[:notice] = "Assignments updated"
    redirect_to collection_potential_matches_path(@collection)
  end
  
  def create
    # create a new (presumably pinch hit) assignment
    assignment = ChallengeAssignment.new(params[:challenge_assignment])
    if assignment.save
      assignment.send_out!
      flash[:notice] = "New assignment created and sent."
    else
      flash[:error] = "We couldn't save the new assignment."
    end
    if params[:assignment_to_cover] && (@old_assignment = ChallengeAssignment.find(params[:assignment_to_cover]))
      @old_assignment.covered_at = Time.now
      @old_assignment.save
    end
    redirect_to collection_assignments_path(@collection)
  end
  
  def purge
    ChallengeAssignment.clear!(@collection)
    @challenge.assignments_sent_at = nil
    @challenge.save
    flash[:notice] = "Assignments purged!"
    redirect_to collection_path(@collection)
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
  
  def ignore_default
    @challenge_assignment.covered_at = Time.now
    @challenge_assignment.save
    flash[:notice] = "Assignment marked as covered, it will not appear in the defaulted list anymore."
    redirect_to collection_assignments_path(@collection)
  end
  
end
