class Request < Prompt

  def get_prompt_restriction
    if collection && collection.challenge
      collection.challenge.request_restriction
    else
      nil
    end
  end


end