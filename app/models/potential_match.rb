class PotentialMatch < ActiveRecord::Base
  
  # We use "-1" to represent all the requested items matching 
  ALL = -1

  CACHE_PROGRESS_KEY = "potential_match_status_for_"
  CACHE_INTERRUPT_KEY = "potential_match_interrupt_for_"

  belongs_to :collection
  belongs_to :offer_signup, :class_name => "ChallengeSignup"
  belongs_to :request_signup, :class_name => "ChallengeSignup"
  
  has_many :potential_prompt_matches, :dependent => :destroy

protected

  # note: this will only work if memcache is being used as the cache store,
  # not the built-in memory cache store, as delayed_job doesn't share the 
  # same memory space as the Rails app itself 
  def self.progress_key(collection)
    CACHE_PROGRESS_KEY + "#{collection.id}"
  end
  
  def self.interrupt_key(collection)
    CACHE_INTERRUPT_KEY + "#{collection.id}"
  end
  
public

  def self.clear!(collection)
    # destroy all potential matches in this collection
    PotentialMatch.destroy_all(["collection_id = ?", collection.id])
  end
  
  def self.set_up_generating(collection)
    Rails.cache.write progress_key(collection), collection.signups.order_by_pseud.first.pseud.byline
  end
  
  def self.cancel_generation(collection)
    Rails.cache.write interrupt_key(collection), true
  end

  def self.canceled?(collection)
    !Rails.cache.read(interrupt_key(collection)).nil?
  end

  def self.generate!(collection)
    PotentialMatch.clear!(collection)
    collection.signups.order_by_pseud.each do |request_signup|
      break if Rails.cache.read(interrupt_key(collection))
      PotentialMatch.generate_for_signup(collection, request_signup)
    end
    PotentialMatch.finish_generation(collection)
  end

  def self.generate_for_signup(collection, request_signup)
    Rails.cache.write progress_key(collection), request_signup.pseud.byline
    collection.signups.each do |offer_signup|
      next if request_signup == offer_signup
      potential_match = request_signup.match(offer_signup)
      potential_match.save if potential_match && potential_match.valid?
    end
  end

  def self.finish_generation(collection)
    Rails.cache.write progress_key(collection), nil
    if Rails.cache.read(interrupt_key(collection))
      Rails.cache.write interrupt_key(collection), false
      PotentialMatch.clear!(collection)
    else
      ChallengeAssignment.generate!(collection)
      UserMailer.potential_match_generation_notification(collection).deliver
    end
  end

  def self.in_progress?(collection)
    !Rails.cache.read(progress_key(collection)).nil?
  end

  def self.position(collection)
    Rails.cache.read(progress_key(collection))
  end

  # sorting routine for potential matches
  include Comparable
  def <=>(other)
    return 0 if self.id == other.id 

    # start with seeing how many offers/requests match
    cmp = compare_all(self.num_prompts_matched, other.num_prompts_matched)
    return cmp unless cmp == 0
    
    # otherwise we rank them based on how good the prompt matches are
    self_tally = 0
    other_tally = 0
    self.potential_prompt_matches.each do |self_prompt_match|
      other.potential_prompt_matches.each do |other_prompt_match|
        if self_prompt_match > other_prompt_match 
          self_tally = self_tally + 1
        elsif other_prompt_match > self_prompt_match 
          other_tally = other_tally + 1
        end
      end
    end
    cmp = (self_tally <=> other_tally)
    return cmp unless cmp == 0
    
    # if we're a perfect match down to here just match on id
    return self.id <=> other.id
  end

protected
  def compare_all(self_value, other_value)
    self_value == ALL ? (other_value == ALL ? 0 : 1) : (other_value == ALL ? -1 : self_value <=> other_value)
  end

end
