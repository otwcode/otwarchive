class Offer < Prompt
  def get_prompt_restriction
    if collection && collection.challenge
      collection.challenge.offer_restriction
    else
      nil
    end
  end
end