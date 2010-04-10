class ChallengeAssignment < ActiveRecord::Base
  # We use "-1" to represent all the requested items matching 
  ALL = -1

  belongs_to :collection
  belongs_to :offer_signup, :class_name => "ChallengeSignup"
  belongs_to :request_signup, :class_name => "ChallengeSignup"
  belongs_to :pinch_hitter, :class_name => "Pseud"
  belongs_to :pinch_request_signup, :class_name => "ChallengeSignup"
  belongs_to :creation, :polymorphic => true

  named_scope :for_request_signup, lambda {|signup|
    {:conditions => ['request_signup_id = ?', signup.id]}
  }

  named_scope :for_offer_signup, lambda {|signup|
    {:conditions => ['offer_signup_id = ?', signup.id]}
  }

  named_scope :by_offering_user, lambda {|user|
    {
      :select => "DISTINCT challenge_assignments.*",
      :joins => "INNER JOIN challenge_signups ON challenge_assignments.offer_signup_id = challenge_signups.id
                 INNER JOIN pseuds ON challenge_signups.pseud_id = pseuds.id
                 INNER JOIN users ON pseuds.user_id = users.id",
      :conditions => ['users.id = ?', user.id]
    }
  }

  named_scope :by_requesting_user, lambda {|user|
    {
      :select => "DISTINCT challenge_assignments.*",
      :joins => "INNER JOIN challenge_signups ON challenge_assignments.request_signup_id = challenge_signups.id
                 INNER JOIN pseuds ON challenge_signups.pseud_id = pseuds.id
                 INNER JOIN users ON pseuds.user_id = users.id",
      :conditions => ['users.id = ?', user.id]
    }
  }

  named_scope :in_collection, lambda {|collection| {:conditions => ['challenge_assignments.collection_id = ?', collection.id] }}
  
  named_scope :defaulted, {:conditions => ["defaulted_at IS NOT NULL"]}
  named_scope :open, {:conditions => ["defaulted_at IS NULL"]}
  named_scope :uncovered, {:conditions => ["covered_at IS NULL"]}
  named_scope :covered, {:conditions => ["covered_at IS NOT NULL"]}
  
  named_scope :with_offer, {:conditions => ["offer_signup_id IS NOT NULL"]}
  named_scope :with_request, {:conditions => ["request_signup_id IS NOT NULL"]}
  named_scope :with_no_request, {:conditions => ["request_signup_id IS NULL"]}
  named_scope :with_no_offer, {:conditions => ["offer_signup_id IS NULL"]}  

  named_scope :order_by_requesting_pseud, {:joins => {:request_signup => :pseud}, :order => "pseuds.name"}
  named_scope :order_by_offering_pseud, {:joins => {:offer_signup => :pseud}, :order => "pseuds.name"}

  before_destroy :clear_assignment
  def clear_assignment
    if offer_signup
      offer_signup.assigned_as_offer = false
      offer_signup.save
    end

    if request_signup
      request_signup.assigned_as_request = false
      request_signup.save
    end
  end
  
  def get_collection_item
    return nil unless self.creation
    CollectionItem.find(:first, :conditions => ["collection_id = ? AND item_id = ? AND item_type = ?", self.collection_id, self.creation_id, self.creation_type])
  end
  
  def fulfilled?
    self.creation && (item = get_collection_item) && item.approved?
  end

  def defaulted=(value)
    if value == "1"
      self.defaulted_at = Time.now
    else
      self.defaulted_at = nil
    end
  end
      
  def defaulted
    !self.defaulted_at.nil?
  end

  include Comparable
  def <=>(other)
    return -1 if self.request_signup.nil? && other.request_signup
    return 1 if other.request_signup.nil? && self.request_signup
    return -1 if self.offer_signup.nil? && other.offer_signup
    return 1 if other.offer_signup.nil? && self.offer_signup
    cmp = self.request_byline.downcase <=> other.request_byline.downcase
    return cmp if cmp != 0
    self.offer_byline.downcase <=> other.offer_byline.downcase
  end
  
  def title
    "#{self.collection.title} (#{self.request_byline})"
  end
  
  def offering_user
    offering_pseud ? offering_pseud.user : nil
  end
  
  def offering_pseud
    offer_signup ? offer_signup.pseud : pinch_hitter
  end
  
  def requesting_pseud
    request_signup ? request_signup.pseud : (request_pinch_signup ? request_pinch_signup.pseud : nil)
  end
  
  def offer_byline
    offer_signup ? offer_signup.pseud.byline : (pinch_hitter ? (pinch_hitter.byline + "* (pinch hitter)") : "- none -")
  end
  
  def request_byline
    request_signup ? request_signup.pseud.byline : (pinch_request_signup ? (pinch_request_byline + "* (pinch recipient)") : "- None -")
  end

  def pinch_hitter_byline
    pinch_hitter ? pinch_hitter.byline : ""
  end
  
  def pinch_hitter_byline=(byline)
    self.pinch_hitter = Pseud.by_byline(byline).first
  end

  def pinch_request_byline
    pinch_request_signup ? pinch_request_signup.pseud.byline : ""
  end

  def pinch_request_byline=(byline)
    pinch_pseud = Pseud.by_byline(byline).first
    self.pinch_request_signup = ChallengeSignup.in_collection(self.collection).by_pseud(pinch_pseud).first if pinch_pseud
  end
  
  def send_out!
    # don't resend!
    unless self.sent_at
      self.sent_at = Time.now
      save
      assigned_to = self.offer_signup ? self.offer_signup.pseud.user : (self.pinch_hitter ? self.pinch_hitter.user : nil)
      request = self.request_signup || self.pinch_request_signup
      UserMailer.deliver_challenge_assignment_notification(collection, assigned_to, self) if assigned_to && request
    end
  end

  # send assignments out to all participants 
  def self.send_out!(collection)
    collection.assignments.each do |assignment|
      assignment.send_out!
    end
    collection.notify_maintainers("Assignments Sent", "All assignments have now been sent out.")
  end

  # generate automatic match for a collection
  # this requires potential matches to already be generated
  def self.generate!(collection)
    ChallengeAssignment.clear!(collection)
    
    # we sort signups into buckets based on how many potential matches they have
    @request_match_buckets = {}
    @offer_match_buckets = {}
    @max_match_count = 0
    collection.signups.each do |signup|
      request_match_count = signup.request_potential_matches.count
      @request_match_buckets[request_match_count] ||= []
      @request_match_buckets[request_match_count] << signup
      @max_match_count = (request_match_count > @max_match_count ? request_match_count : @max_match_count)

      offer_match_count = signup.offer_potential_matches.count
      @offer_match_buckets[offer_match_count] ||= []
      @offer_match_buckets[offer_match_count] << signup
      @max_match_count = (offer_match_count > @max_match_count ? offer_match_count : @max_match_count)
    end

    # now that we have the buckets, we go through assigning people in order
    # of people with the fewest options first.
    # if someone has no potential matches they still get an assignment, just with no 
    # match.
    0.upto(@max_match_count) do |count|
      if @request_match_buckets[count]
        @request_match_buckets[count].sort_by {rand}.each do |request_signup|
          # go through the potential matches in order from best to worst and try and assign
          request_signup.reload
          next if request_signup.assigned_as_request
          ChallengeAssignment.assign_request!(collection, request_signup)
        end
      end
        
      if @offer_match_buckets[count]
        @offer_match_buckets[count].sort_by {rand}.each do |offer_signup|
          offer_signup.reload
          next if offer_signup.assigned_as_offer
          ChallengeAssignment.assign_offer!(collection, offer_signup)
        end
      end
    end
  end
    
  # go through the request's potential matches in order from best to worst and try and assign
  def self.assign_request!(collection, request_signup)
    assignment = ChallengeAssignment.new(:collection => collection, :request_signup => request_signup)
    last_choice = nil
    assigned = false
    request_signup.request_potential_matches.sort.reverse.each do |potential_match|
      # skip if this signup has already been assigned as an offer
      next if potential_match.offer_signup.assigned_as_offer
      
      # if there's a circular match let's save it as our last choice
      if potential_match.offer_signup.assigned_as_request && !last_choice && collection.assignments.for_request_signup(potential_match.offer_signup).first.offer_signup == request_signup
        last_choice = potential_match
        next
      end

      # otherwise let's use it
      assigned = ChallengeAssignment.do_assign_request!(assignment, potential_match)
      break
    end

    if !assigned && last_choice
      ChallengeAssignment.do_assign_request!(assignment, last_choice)
    end

    request_signup.assigned_as_request = true
    request_signup.save!

    assignment.save!
    assignment
  end

  # go through the offer's potential matches in order from best to worst and try and assign
  def self.assign_offer!(collection, offer_signup)
    assignment = ChallengeAssignment.new(:collection => collection, :offer_signup => offer_signup)
    last_choice = nil
    assigned = false
    offer_signup.offer_potential_matches.sort.reverse.each do |potential_match|
      # skip if already assigned as a request
      next if potential_match.request_signup.assigned_as_request

      # if there's a circular match let's save it as our last choice
      if potential_match.request_signup.assigned_as_offer && !last_choice && collection.assignments.for_offer_signup(potential_match.request_signup).first.request_signup == offer_signup
        last_choice = potential_match
        next
      end

      # otherwise let's use it
      assigned = ChallengeAssignment.do_assign_offer!(assignment, potential_match)
      break
    end

    if !assigned && last_choice
      ChallengeAssignment.do_assign_offer!(assignment, last_choice)
    end

    offer_signup.assigned_as_offer = true
    offer_signup.save!
    
    assignment.save!
    assignment
  end

  
  def self.do_assign_request!(assignment, potential_match)
    assignment.offer_signup = potential_match.offer_signup
    potential_match.offer_signup.assigned_as_offer = true
    potential_match.offer_signup.save!
  end

  
  def self.do_assign_offer!(assignment, potential_match)
    assignment.request_signup = potential_match.request_signup
    potential_match.request_signup.assigned_as_request = true
    potential_match.request_signup.save!
  end



  # clear out all previous assignments
  def self.clear!(collection)
    ChallengeAssignment.destroy_all(["collection_id = ?", collection.id])
  end

  # create placeholders for any assignments left empty
  # (this is for after manual updates have left some users without an 
  # assignment)
  def self.update_placeholder_assignments!(collection)
    collection.signups.each do |signup|
      if signup.request_assignments.count > 1
        # get rid of empty placeholders no longer needed
        signup.request_assignments.each do |assignment|
          assignment.destroy if assignment.offer_signup.blank?
        end
      end
      if signup.request_assignments.empty?
        # not assigned to giver anymore! :(
        assignment = ChallengeAssignment.new(:collection => collection, :request_signup => signup)
        assignment.save
      end
      if signup.offer_assignments.count > 1
        signup.offer_assignments.each do |assignment|
          assignment.destroy if assignment.request_signup.blank?
        end
      end
      if signup.offer_assignments.empty?
        assignment = ChallengeAssignment.new(:collection => collection, :offer_signup => signup)
        assignment.save
      end
    end
  end

end
