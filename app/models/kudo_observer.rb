class KudoObserver < ActiveRecord::Observer

  def after_create(kudo)
    users = kudo.commentable.pseuds.map(&:user)

    users.each do |user|
      if notify_user_by_email?(user)
        KudoMailer.kudo_notification(user.id, kudo.id).deliver
      end
    end
  end


  protected
    def notify_user_by_email?(user)
      user.nil? ? false : ( user.is_a?(Admin) ? :true :
        !(user == User.orphan_account || user.preference.kudos_emails_off?) )
    end

end
