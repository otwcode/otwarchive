class ChallengeSignupSweeper < ActionController::Caching::Sweeper
  observe ChallengeSignup
  
  def after_create(signup)
    expire_cache_for(signup)
  end

  def after_update(signup)
    expire_cache_for(signup)
  end

  def after_destroy(signup)
    expire_cache_for(signup)
  end
  
  private
  def expire_cache_for(signup)
    # expire the signup summary for this particular signup's collection and then
    # populate it again using a delayed job
    expire_fragment("signup_summary_#{signup.collection.id}")
  end

end