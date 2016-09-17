class ChallengeSignupSummary

  attr_reader :collection, :challenge

  def initialize(collection)
    @collection = collection
    @challenge = collection.challenge
  end

  # Returns an array of tag listings that includes the number of requests and
  # offers each tag has in this challenge, sorted by least-offered and most-requested
  def summary
    @summary ||= tags.map { |tag| tag_summary(tag) }.compact.sort
  end

  private

  # The class of tags to be summarized
  # For a multi-fandom challenge, this is probably Fandom, but for a single-fandom 
  # challenge, it may be something else
  def tag_class
    raise "Redshirt: Attempted to constantize invalid class initialize tag_class #{challenge.topmost_tag_type.classify}" unless Tag::TYPES.include?(challenge.topmost_tag_type.classify)
    challenge.topmost_tag_type.classify.constantize
  end

  # All of the tags of the desired type that have been
  # used in requests or offers for this challenge
  def tags
    @tags ||= tag_class.in_challenge(collection)
  end
  
  def tag_summary(tag)
    request_count = Request.in_collection(collection).with_tag(tag).count
    offer_count = Offer.in_collection(collection).with_tag(tag).count

    if request_count > 0
      ChallengeSignupTagSummary.new(tag.id, tag.name, request_count, offer_count)
    end
  end

end

class ChallengeSignupTagSummary < Struct.new(:id, :name, :requests, :offers)

  # Prioritize tags with the fewest offers and most requests
  # If they have the same number of offers and requests, sort by name
  def <=>(other)
    if self.offers == other.offers
      if self.requests == other.requests
        self.name <=> other.name
      else
        other.requests <=> self.requests
      end
    else
      self.offers <=> other.offers
    end
  end

end
