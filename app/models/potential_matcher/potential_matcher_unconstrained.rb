# A class used to generate PotentialMatch objects when the matching is
# unconstrained -- that is, anyone can be assigned to anyone else.
class PotentialMatcherUnconstrained
  def initialize(collection, batch_size = 100)
    @collection = collection
    @batch_size = batch_size
    @sample_size = ArchiveConfig.POTENTIAL_MATCHES_MAX

    # Set up a new progress object for recording our progress.
    @progress = PotentialMatcherProgress.new(collection)
  end

  def sample_offers_for_request(request_id, offer_ids)
    # Sample one extra to make sure that we can avoid sampling the request_id.
    sampled = offer_ids.sample(@sample_size + 1)

    # Delete the request_id if it's in the sample; otherwise, delete an
    # arbitrary id from the sample. (Array.sample returns the items in random
    # order.)
    sampled.delete(request_id)
    sampled.pop if sampled.size > @sample_size

    sampled
  end

  # Generates potential match objects for the given request and each offer_id
  # in the given list. (Doesn't load the offers, because this should only be
  # called if the matching is unconstrained, and we don't need any info about
  # the offers to generate PotentialMatch objects.)
  def make_signup_matches(request, offer_ids)
    @progress.start_subtask(offer_ids.size)

    offer_ids.each do |offer_id|
      PotentialMatch.create(collection: @collection,
                            offer_signup_id: offer_id,
                            request_signup: request,
                            num_prompts_matched: request.requests.size)

      @progress.increment
    end

    @progress.end_subtask
  end

  # Generates all potential matches for the collection, under the assumption
  # that matching isn't constrained (so that everyone can match with everyone
  # else, and all matches are equally good).
  def generate
    # We don't need tags to generate unconstrained, but we do need to know
    # how many requests each signup has (to set num_prompts_matched).
    requests = @collection.signups.includes(:requests)

    # We don't even need the offers themselves, just the IDs.
    offer_ids = @collection.signups.pluck(:id)

    @progress.start_subtask(offer_ids.size)

    requests.find_in_batches(batch_size: @batch_size) do |request_signups|
      break if PotentialMatch.canceled?(@collection)

      request_signups.each do |request|
        break if PotentialMatch.canceled?(@collection)

        sampled_offer_ids = sample_offers_for_request(request.id, offer_ids)
        make_signup_matches(request, sampled_offer_ids)

        @progress.increment
      end
    end

    @progress.end_subtask
  end
end
