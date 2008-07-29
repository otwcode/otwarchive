class UserObserver < ActiveRecord::Observer
  def after_create(user)
    unless user == User.orphan_account
      UserMailer.deliver_signup_notification(user)
    end
  end

  def after_save(user)
    unless user == User.orphan_account
      UserMailer.deliver_activation(user) if user.pending?
    end
  end

end
