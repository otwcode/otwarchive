class UserObserver < ActiveRecord::Observer
  def after_create(user)
		orphan_account = User.orphan_account
		unless user == orphan_account
			UserMailer.deliver_signup_notification(user)
		end
  end

  def after_save(user)
		orphan_account = User.orphan_account
		unless user == orphan_account
			UserMailer.deliver_activation(user) if user.pending?
		end
  end

end


