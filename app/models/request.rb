class Request < Prompt
  belongs_to :challenge_signup, :touch => true, :inverse_of => :requests

  def get_prompt_restriction
    if collection && collection.challenge
      collection.challenge.request_restriction
    else
      nil
    end
  end


end
