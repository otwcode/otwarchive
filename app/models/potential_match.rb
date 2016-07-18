class PotentialMatch < ActiveRecord::Base

  # We use "-1" to represent all the requested items matching
  ALL = -1

  CACHE_PROGRESS_KEY = "potential_match_status_for_".freeze
  CACHE_SIGNUP_KEY = "potential_match_signups_for_".freeze
  CACHE_INTERRUPT_KEY = "potential_match_interrupt_for_".freeze
  CACHE_INVALID_SIGNUP_KEY = "potential_match_invalid_signup_for_".freeze

  belongs_to :collection
  belongs_to :offer_signup, class_name: "ChallengeSignup"
  belongs_to :request_signup, class_name: "ChallengeSignup"

  has_many :potential_prompt_matches, dependent: :destroy

protected

  def self.progress_key(collection)
    CACHE_PROGRESS_KEY + "#{collection.id}"
  end

  def self.signup_key(collection)
    CACHE_SIGNUP_KEY + "#{collection.id}"
  end

  def self.interrupt_key(collection)
    CACHE_INTERRUPT_KEY + "#{collection.id}"
  end

  def self.invalid_signup_key(collection)
    CACHE_INVALID_SIGNUP_KEY + "#{collection.id}"
  end

public

  def self.clear!(collection)
    # rapidly delete all potential prompt matches and potential matches
    # WITHOUT CALLBACKS
    pmids = collection.potential_matches.value_of(:id)
    # trash all the potential PROMPT matches first
    # since we are NOT USING CALLBACKS
    PotentialPromptMatch.where("potential_match_id IN (?)", pmids).delete_all
    # now take out the potential matches
    PotentialMatch.where("id IN (?)", pmids).delete_all
  end

  def self.set_up_generating(collection)
    REDIS_GENERAL.set progress_key(collection), collection.signups.first.id
  end

  def self.cancel_generation(collection)
    REDIS_GENERAL.set interrupt_key(collection), "1"
  end

  def self.canceled?(collection)
    REDIS_GENERAL.get(interrupt_key(collection)) == "1"
  end

  @queue = :collection

  # This only works on class methods
  def self.perform(method, *args)
    self.send(method, *args)
  end

  def self.generate(collection)
    Resque.enqueue(self, :generate_in_background, collection.id)
  end

  # Regenerate the potential matches for a given signup
  def self.regenerate_for_signup(signup)
    Resque.enqueue(self, :regenerate_for_signup_in_background, signup.id)
  end

  def self.invalid_signups_for(collection)
    REDIS_GENERAL.smembers(invalid_signup_key(collection))
  end

  def self.clear_invalid_signups(collection)
    REDIS_GENERAL.del invalid_signup_key(collection)
  end

  # The actual method that generates the potential matches for an entire collection
  def self.generate_in_background(collection_id)
    collection = Collection.find(collection_id)

    # check for invalid signups
    PotentialMatch.clear_invalid_signups(collection)
    invalid_signup_ids = collection.signups.select {|s| !s.valid?}.collect(&:id)
    unless invalid_signup_ids.empty?
      invalid_signup_ids.each {|sid| REDIS_GENERAL.sadd invalid_signup_key(collection), sid}
      UserMailer.invalid_signup_notification(collection.id, invalid_signup_ids).deliver
      PotentialMatch.cancel_generation(collection)
    else

      PotentialMatch.clear!(collection)
      settings = collection.challenge.potential_match_settings

      # start by collecting the ids of all the tag sets of the offers/requests in this collection
      collection_tag_sets = Prompt.where(collection_id: collection.id).value_of(:tag_set_id, :optional_tag_set_id).flatten.compact

      # the topmost tags required for matching
      required_types = settings.required_types.map {|t| t.classify}

      # treat each signup as a request signup first
      # because find_each doesn't give us a consistent order, but we don't necessarily
      # want to load all the signups into memory with each, we get the ids first and 
      # load each signup as needed
      signup_ids = collection.signups.value_of(:id)
      signup_ids.each do |signup_id|
        break if PotentialMatch.canceled?(collection)
        signup = ChallengeSignup.find(signup_id)
        REDIS_GENERAL.set progress_key(collection), signup.id
        PotentialMatch.generate_for_signup(collection, signup, settings, collection_tag_sets, required_types)
      end

    end
    # TODO: for any signups with no potential matches try regenerating?
    PotentialMatch.finish_generation(collection)
  end

  # Generate potential matches for a signup in the general process
  def self.generate_for_signup(collection, signup, settings, collection_tag_sets, required_types, prompt_type = "request")
    potential_match_count = 0
    max_matches = [
      (collection.signups.count / ArchiveConfig.POTENTIAL_MATCHES_PERCENT),
      ArchiveConfig.POTENTIAL_MATCHES_MAX
    ].min
    max_matches = [max_matches, ArchiveConfig.POTENTIAL_MATCHES_MIN].max

    # only check the signups that have any overlap
    match_signup_ids = PotentialMatch.matching_signup_ids(collection, signup, collection_tag_sets, required_types, prompt_type)

    # We randomize the signup ids to make sure potential matches are distributed across all the participants
    match_signup_ids.sort_by {rand}.each do |other_signup_id|
      next if signup.id == other_signup_id
      other_signup = ChallengeSignup.find(other_signup_id)

      # The "match" method of ChallengeSignup creates and returns a new (unsaved) potential match object
      # It assumes the signup that is calling is the requesting signup, so if this is meant to be an offering signup
      #  instead, we call it from the other signup
      potential_match = (prompt_type == "request") ? signup.match(other_signup, settings) : other_signup.match(signup, settings)
      if potential_match && potential_match.valid?
        potential_match.save
        potential_match_count += 1
      end

      # Stop looking if we've hit the max
      break if potential_match_count == max_matches
    end
  end

  # Get a random set of signups to examine
  def self.random_signup_ids(collection)
    collection.signups.order("RAND()").limit(ArchiveConfig.POTENTIAL_MATCHES_MAX).value_of(:id)
  end

  # Get the ids of all signups that have some overlap in the tag types required for matching
  def self.matching_signup_ids(collection, signup, collection_tag_sets, required_types, prompt_type = "request")
    matching_signup_ids = []

    if required_types.empty?
      # nothing is required, so any signup can match -- check a random selection
      return PotentialMatch.random_signup_ids(collection)
    end

    # get the tagsets used in the signup we are trying to match
    signup_tagsets = signup.send(prompt_type.pluralize).value_of(:tag_set_id, :optional_tag_set_id).flatten.compact

    # get the ids of all the tags of the required types in the signup's tagsets
    signup_tags = SetTagging.where(tag_set_id: signup_tagsets).joins(:tag).where("tags.type IN (?)", required_types).value_of(:tag_id)

    if signup_tags.empty?
      # a match is required by the settings but the user hasn't put any of the required tags in, meaning they are open to anything
      return PotentialMatch.random_signup_ids(collection)
    else
      # now find all the tagsets in the collection that share the original signup's tags
      match_tagsets = SetTagging.where(tag_id: signup_tags, tag_set_id: collection_tag_sets).value_of(:tag_set_id).uniq

      # and now we look up any signups that have one of those tagsets in the opposite position -- ie,
      # if this signup is a request, we are looking for offers with the same tag; if it's an offer, we're
      # looking for requests with the same tag.
      matching_signup_ids = (prompt_type == "request" ? "Offer" : "Request").constantize.
                         where("tag_set_id IN (?) OR optional_tag_set_id IN (?)", match_tagsets, match_tagsets).
                         value_of(:challenge_signup_id).compact.uniq

      # now add on "any" matches for the required types
      condition = "any_#{required_types.first.downcase} = 1"
      matching_signup_ids += collection.prompts.where(condition).order("RAND()").limit(ArchiveConfig.POTENTIAL_MATCHES_MAX).value_of(:challenge_signup_id).uniq
    end

    return matching_signup_ids
  end

  # Regenerate potential matches for a single signup within a challenge where (presumably)
  # the other signups already have matches generated.
  # To do this, we have to regenerate its potential matches both as a request and as an offer
  # (instead of just generating them as a request as we do when generating ALL potential matches)
  def self.regenerate_for_signup_in_background(signup_id)
    signup = ChallengeSignup.find(signup_id)
    collection = signup.collection

    # Get all the data
    settings = collection.challenge.potential_match_settings
    collection_tag_sets = Prompt.where(collection_id: collection.id).value_of(:tag_set_id, :optional_tag_set_id).flatten.compact
    required_types = settings.required_types.map {|t| t.classify}

    # clear the existing potential matches for this signup in each direction
    signup.offer_potential_matches.destroy_all
    signup.request_potential_matches.destroy_all

    # We check the signup in both directions -- as a request signup and as an offer signup
    %w(request offer).each do |prompt_type|
      PotentialMatch.generate_for_signup(collection, signup, settings, collection_tag_sets, required_types, prompt_type)
    end
  end

  # Finish off the potential match generation
  def self.finish_generation(collection)
    REDIS_GENERAL.del progress_key(collection)
    REDIS_GENERAL.del signup_key(collection)
    if PotentialMatch.canceled?(collection)
      REDIS_GENERAL.del interrupt_key(collection)
      # eventually we'll want to be able to pick up where we left off,
      # but not there yet
      PotentialMatch.clear!(collection)
    else
      ChallengeAssignment.delayed_generate(collection.id)
    end
  end

  def self.in_progress?(collection)
    if REDIS_GENERAL.get(progress_key(collection))
      if PotentialMatch.canceled?(collection)
        self.finish_generation(collection)
        return false
      end
      return true
    end
    false
  end

  def self.position(collection)
    signup_id = REDIS_GENERAL.get progress_key(collection)
    ChallengeSignup.find(signup_id).pseud.byline
  end

  def self.progress(collection)
    # the index of our current signup person in the full index of signup participants
    current_id = REDIS_GENERAL.get(progress_key(collection))
    collection_signup_key = signup_key(collection)
    unless REDIS_GENERAL.exists(collection_signup_key)
      score = 0
      # we have to get the signups in the same order as they are processed 
      # for this to work
      collection.signups.value_of(:id).each do |signup_id|
        REDIS_GENERAL.zadd collection_signup_key, score, signup_id
        score += 1
      end
    end
    rank = REDIS_GENERAL.zrank(collection_signup_key, current_id)
    if rank.nil?
      return -1
    else
      number_of_bylines = REDIS_GENERAL.zcount(collection_signup_key, 0, "+inf")
      # we want a percentage: multiply by 100 first so we can keep this an integer calculation
      return (rank * 100) / number_of_bylines
    end
  end

  # sorting routine -- this gets used to rank the relative goodness of potential matches
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
