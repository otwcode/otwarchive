# Generates potential matches when the matching settings restrict who can be
# matched with whom. Uses PromptBatches to speed up matching. Does not generate
# assignments.
#
# The runtime is asymptotically quadratic in the number of signups, but the
# batching keeps the constants relatively low.
#
# Interestingly enough, this will still work for unconstrained matches, thanks
# to some weirdness with having nil as the @index_tag_type. But it does a lot
# of extra work generating prompt matches that's really unnecessary when the
# matching is unconstrained, so it probably shouldn't be used for those
# purposes.
class PotentialMatcherConstrained
  ALL = -1

  attr_reader :collection, :settings, :batch_size
  attr_reader :index_tag_type, :index_optional

  def initialize(collection, batch_size = 100, enable_progress = true)
    @collection = collection
    @settings = collection.challenge.potential_match_settings
    @batch_size = batch_size

    @required_types = @settings.required_types
    unless @required_types.empty?
      @index_tag_type = @required_types.first
      @index_optional = @settings.include_optional?(@index_tag_type)
    end

    # Set up a new progress object for recording our progress.
    @progress = PotentialMatcherProgress.new(collection, enable_progress)
  end

  private

  # Makes a batch for the given set of signups.
  # Passes @index_tag_type and @index_optional to the constructor, so that the
  # prompt batch knows how to build its indices properly.
  def make_batch(signups, prompt_type)
    PromptBatch.new(signups, prompt_type, @index_tag_type, @index_optional)
  end

  # Generates (but doesn't save) all potential prompt matches between the given
  # challenge signup (to be used as a request), and the batch of offers.
  def make_prompt_matches(request_signup, offer_batch)
    prompt_matches_for_signup = []

    request_signup.requests.each do |request|
      offer_candidates = offer_batch.candidates_for_matching(request)
      offer_candidates.each do |offer|
        match = request.match(offer, settings)
        prompt_matches_for_signup << match unless match.nil?
      end
    end

    prompt_matches_for_signup
  end

  # Combines a list of PotentialPromptMatches into a single PotentialMatch
  # object (not saved). Returns nil if the list of prompt_matches doesn't have
  # enough matches to satisfy @settings.num_required_prompts.
  def combine_prompt_matches(request, offer, prompt_matches)
    required_matches = @settings.num_required_prompts
    required_matches = request.requests.size if required_matches == ALL

    # TODO: Maybe this should be checking the number of requests covered by
    # prompt_matches, rather than the total number of matches? Do we want to
    # allow a match when we're supposed to be matching ALL, but (for example)
    # there are really three requests and three offers, with only two matching
    # requests and two matching offers (for a total of four prompt matches)?
    return nil if prompt_matches.size < required_matches

    match = PotentialMatch.new(collection: @collection,
                               offer_signup: offer,
                               request_signup: request,
                               num_prompts_matched: prompt_matches.size)

    match.potential_prompt_matches = prompt_matches
    match
  end

  # Takes as input a list of PotentialPromptMatches, and groups them together
  # by their offer signup ID. (The request signup ID is assumed to be the
  # same.) Those groups are then passed into the combine_prompt_matches
  # function to try to generate new PotentialMatch objects.
  def make_signup_matches(prompt_matches_for_request)
    grouped = prompt_matches_for_request.group_by do |prompt_match|
      prompt_match.offer.challenge_signup_id
    end

    signup_matches_for_request = []

    grouped.each_value do |prompt_matches|
      # All of the request signups and all of the offer signups are the same
      # for every prompt match in this group, so we can just look them up in
      # the first prompt_match.
      request = prompt_matches.first.request.challenge_signup
      offer = prompt_matches.first.offer.challenge_signup
      signup_match = combine_prompt_matches(request, offer, prompt_matches)
      signup_matches_for_request << signup_match unless signup_match.nil?
    end

    signup_matches_for_request
  end

  # Save all signup matches. Use a transaction because it's marginally faster,
  # and we like speed.
  def save_signup_matches(signup_matches)
    PotentialMatch.transaction do
      signup_matches.each(&:save)
    end
  end

  # Generates (and saves) all PotentialMatches for the given request batch and
  # offer batch.
  def make_batch_matches(request_batch, offer_batch)
    @progress.start_subtask(request_batch.signups.size)

    request_batch.signups.each do |request_signup|
      prompt_matches = make_prompt_matches(request_signup, offer_batch)
      signup_matches = make_signup_matches(prompt_matches)
      save_signup_matches(signup_matches)
      @progress.increment
    end

    @progress.end_subtask
  end

  public

  # Generates all potential matches for the collection.
  def generate
    # These two lines won't trigger SQL queries (which is good, because that'd
    # be an awful lot of data to load). They're just defining relations that we
    # can call find_in_batches on.
    offers = @collection.signups.with_offer_tags
    requests = @collection.signups.with_request_tags

    # We process a quadratic number of batch pairs.
    batch_count = 1 + (@collection.signups.count - 1) / @batch_size
    @progress.start_subtask(batch_count * batch_count)

    offers.find_in_batches(batch_size: @batch_size) do |offer_signups|
      offer_batch = make_batch(offer_signups, :offers)

      requests.find_in_batches(batch_size: @batch_size) do |request_signups|
        return if PotentialMatch.canceled?(@collection)

        request_batch = make_batch(request_signups, :requests)
        make_batch_matches(request_batch, offer_batch)

        @progress.increment
      end
    end

    @progress.end_subtask
  end
end
