class PotentialMatch < ActiveRecord::Base

  # We use "-1" to represent all the requested items matching
  ALL = -1

  CACHE_PROGRESS_KEY = "potential_match_status_for_"
  CACHE_BYLINE_KEY = "potential_match_bylines_for_"
  CACHE_INTERRUPT_KEY = "potential_match_interrupt_for_"

  belongs_to :collection
  belongs_to :offer_signup, :class_name => "ChallengeSignup"
  belongs_to :request_signup, :class_name => "ChallengeSignup"

  has_many :potential_prompt_matches, :dependent => :destroy

protected

  def self.progress_key(collection)
    CACHE_PROGRESS_KEY + "#{collection.id}"
  end
  
  def self.byline_key(collection)
    CACHE_BYLINE_KEY + "#{collection.id}"
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
    $redis.set progress_key(collection), collection.signups.order_by_pseud.pseud_only.first.pseud.byline
  end

  def self.cancel_generation(collection)
    $redis.set interrupt_key(collection), "1"
  end

  def self.canceled?(collection)
    $redis.get(interrupt_key(collection)) == "1"
  end

  @queue = :collection
  def self.generate(collection)
    Resque.enqueue(self, collection.id)
  end
  def self.perform(collection_id)
     self.generate_in_background(Collection.find(collection_id))
  end
  def self.generate_in_background(collection)
    PotentialMatch.clear!(collection)
    settings = collection.challenge.potential_match_settings
    collection.signups.order_by_pseud.includes(:pseud, :requests => [{:tag_set => :tags}]).each do |request_signup|
      break if PotentialMatch.canceled?(collection)
      PotentialMatch.generate_for_signup(collection, request_signup, settings)
    end
    PotentialMatch.finish_generation(collection)
  end

  def self.generate_for_signup(collection, request_signup, settings)
    $redis.set progress_key(collection), request_signup.pseud.byline
    collection.signups.includes(:pseud, :offers => [{:tag_set => :tags}]).each do |offer_signup|
      next if request_signup == offer_signup
      potential_match = request_signup.match(offer_signup, settings)
      potential_match.save if potential_match && potential_match.valid?
    end
  end

  def self.finish_generation(collection)
    $redis.del progress_key(collection)
    $redis.del byline_key(collection)
    if PotentialMatch.canceled?(collection)
      $redis.del interrupt_key(collection)
      PotentialMatch.clear!(collection)
    else
      ChallengeAssignment.delayed_generate(collection)
    end
  end

  def self.in_progress?(collection)
    if $redis.get(progress_key(collection))
      if PotentialMatch.canceled?(collection)
        self.finish_generation(collection)
        return false
      end
      return true
    end
    false
  end

  def self.position(collection)
    $redis.get progress_key(collection)
  end

  def self.progress(collection)
    # the index of our current signup person in the full index of signup participants
    current_byline = $redis.get(progress_key(collection))
    key = byline_key(collection)
    unless $redis.exists(key)
      score = 0
      collection.signups.order_by_pseud.pseud_only.each do |pseud|
        $redis.zadd key, score, pseud.byline
        score += 1
      end
    end
    progress = ($redis.zrank(key, current_byline)/$redis.zcount(key, 0, "+inf")) * 100
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
