class UserObserver < ActiveRecord::Observer
  def after_create(user)
    unless user == User.orphan_account
      UserMailer.signup_notification(user).deliver unless user.activation_code.nil?
    end
  end

  def after_save(user)
    unless user == User.orphan_account
      UserMailer.activation(user).deliver if !user.active?
    end
  end

end
