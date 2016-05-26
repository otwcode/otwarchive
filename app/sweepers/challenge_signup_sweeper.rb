class ChallengeSignupSweeper < ActionController::Caching::Sweeper
  observe ChallengeSignup
  
  def after_save(record)
    expire_challenge_signup_cache_for(record)
  end

  def after_destroy(record)
    expire_challenge_signup_cache_for(record)
  end
  
  private
  # return one or many collections associated with the changed record 
  # converted into an array
  def get_collections_from_record(record)
    if record.is_a?(Collection)
      # send collection, its parent, and any children 
      ([record, record.parent] + record.children).compact
    elsif record.respond_to?(:collection) && !record.collection.nil?
      ([record.collection, record.collection.parent] + record.collection.children).compact
    elsif record.respond_to?(:collections)
      (record.collections + record.collections.collect(&:parent) + record.collections.collect(&:children).flatten).compact
    else
      []
    end
  end
  
  def get_requests_from_record(record, collection)
    Prompt.find(:collection => collection, :type => 'request', :challenge_signup => record)
  end
      
  # Whenever these records are updated, we need to blank out the collections cache
  def expire_challenge_signup_cache_for(record)
    collections = get_collections_from_record(record)
    collections.each do |collection|
      requests = get_requests_from_record(record, collection)
      requests.each do |request|
        # expire the request summary
        expire_fragment("collection-#{collection.id}-request-#{request.id}")
        # expire the prompt summary too - done in the model
        # and the collection blurb, for the stats
        expire_fragment("collection-blurb-#{collection.id}-v2")
        expire_fragment("collection-profile-#{collection.id}")
      end
      # expire the signup summary, for prompt meme challenge prompts index
      expire_fragment("collection-#{collection.id}-signup-#{record.id}")
    end
  end

end
