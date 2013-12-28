class ChallengeAssignmentsController < ApplicationController

  before_filter :users_only
  before_filter :load_collection, :except => [:index, :default]
  before_filter :collection_owners_only, :except => [:index, :show, :default]
  before_filter :load_assignment_from_id, :only => [:show, :default, :undefault, :cover_default, :uncover_default]

  before_filter :load_challenge, :except => [:index]
  before_filter :check_signup_closed, :except => [:index]
  before_filter :check_assignments_not_sent, :only => [:generate, :set, :send_out]
  before_filter :check_assignments_sent, :only => [:create, :default, :undefault, :cover_default, :uncover_default, :purge]

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



  # ACTIONS

  def index
    if params[:user_id] && (@user = User.find_by_login(params[:user_id]))
      if current_user == @user
        if params[:collection_id] && (@collection = Collection.find_by_name(params[:collection_id]))
          @challenge_assignments = @user.offer_assignments.in_collection(@collection).undefaulted + @user.pinch_hit_assignments.in_collection(@collection).undefaulted
        else
          @challenge_assignments = @user.offer_assignments.undefaulted + @user.pinch_hit_assignments.undefaulted
        end
      else
        flash[:error] = ts("You aren't allowed to see that user's assignments.")
        redirect_to '/' and return
      end
    else
      # do error-checking for the collection case
      return unless load_collection
      @challenge = @collection.challenge if @collection
      signup_open and return unless !@challenge.signup_open
      access_denied and return unless @challenge.user_allowed_to_see_assignments?(current_user)
      
      # we temporarily are ordering by requesting pseud to avoid left join
      @assignments = case
      when params[:pinch_hit]
        # order by pinch hitter name
        ChallengeAssignment.unfulfilled_in_collection(@collection).undefaulted.with_pinch_hitter.joins("INNER JOIN pseuds ON (challenge_assignments.pinch_hitter_id = pseuds.id)").order("pseuds.name")
      when params[:fulfilled]
        @collection.assignments.fulfilled.order_by_requesting_pseud
      when params[:unfulfilled]
        ChallengeAssignment.unfulfilled_in_collection(@collection).undefaulted.order_by_requesting_pseud
      else
        @collection.assignments.defaulted.uncovered.order_by_requesting_pseud
      end
      @assignments = @assignments.page(params[:page])
    end
  end

  def show
    unless @challenge.user_allowed_to_see_assignments?(current_user) || @challenge_assignment.offering_pseud.user == current_user
      flash[:error] = ts("You aren't allowed to see that assignment!")
      redirect_to "/" and return
    end
    if @challenge_assignment.defaulted?
      flash[:notice] = ts("This assignment has been defaulted-on.")
    end
  end

  def generate
    # regenerate assignments using the current potential matches
    ChallengeAssignment.generate(@collection)
    flash[:notice] = ts("Beginning regeneration of assignments. This may take some time, especially if your challenge is large.")
    redirect_to collection_potential_matches_path(@collection)
  end

  def send_out
    ChallengeAssignment.send_out(@collection)
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

  def purge
    ChallengeAssignment.clear!(@collection)
    @challenge.assignments_sent_at = nil
    @challenge.save
    flash[:notice] = "Assignments purged!"
    redirect_to collection_path(@collection)
  end

  def update_multiple
    @errors = []
    params.each_pair do |key, val|
      action, id = key.split(/_/)
      next unless %w(approve default undefault cover).include?(action)
      assignment = ChallengeAssignment.where(:id => id).first
      unless assignment
        @errors << ts("Couldn't find assignment with id #{id}!")
        next
      end
      case action
      when "default"
        # default_assignment_id = y/n
        assignment.default || @errors << ts("We couldn't default the assignment for #{assignment.offer_byline}")
      when "undefault"
        # undefault_[assignment_id] = y/n - if set, undefault
        assignment.defaulted_at = nil
        assignment.save || @errors << ts("We couldn't undefault the assignment covering #{assignment.request_byline}.")
      when "approve"
        assignment.get_collection_item.approve_by_collection if assignment.get_collection_item
      when "cover"
        # cover_[assignment_id] = pinch hitter pseud
        next if val.blank? || assignment.pinch_hitter.try(:byline) == val
        pseud = Pseud.parse_byline(val).first
        if pseud.nil?
          @errors << ts("We couldn't find the user #{val} to assign that to.")
        else
          assignment.cover(pseud) || @errors << ts("We couldn't assign #{val} to cover #{assignment.request_byline}.")
        end
      end
    end
    if @errors.empty?
      flash[:notice] = "Assignment updates complete!"
      redirect_to collection_assignments_path(@collection)
    else
      flash[:error] = @errors
      redirect_to collection_assignments_path(@collection)
    end 
  end

  def default_all
    # mark all unfulfilled assignments as defaulted
    unfulfilled_assignments = ChallengeAssignment.unfulfilled_in_collection(@collection).readonly(false)
    unfulfilled_assignments.update_all :defaulted_at => Time.now
    flash[:notice] = "All unfulfilled assignments marked as defaulting."
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

  def cover_default
    @challenge_assignment.covered_at = Time.now
    @challenge_assignment.save
    flash[:notice] = "Assignment marked as covered. It will not appear in the defaulted list anymore."
    redirect_to collection_assignments_path(@collection)
  end

  def uncover_default
    @challenge_assignment.covered_at = nil
    @challenge_assignment.save
    flash[:notice] = "Assignment marked as uncovered. It will appear in the defaulted list until it is covered."
    redirect_to collection_assignments_path(@collection)
  end

end
