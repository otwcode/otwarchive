=begin
class ChallengeSignupObserver < ActiveRecord::Observer

  # Email a copy of the deleted signup to the user, to cover accidental deletions or modly deletions
  def before_destroy(challenge_signup)
    # must be synchronous because signup is being destroyed
		UserMailer.delete_signup_notification(user, challenge_signup).deliver! 
  end

end
=end
