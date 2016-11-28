class Offer < Prompt
  belongs_to :challenge_signup, :touch => true, :inverse_of => :offers
  
  def get_prompt_restriction
    if collection && collection.challenge
      collection.challenge.offer_restriction
    else
      nil
    end
  end
end
