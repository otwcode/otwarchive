class RelatedWorkObserver < ActiveRecord::Observer
  
  # Send email to authors of parent story, sending them link to approval page 
  def after_create(related_work)
    users = related_work.parent.pseuds.collect(&:user).uniq
		orphan_account = User.orphan_account
    unless users.blank?
      for user in users
        unless user == orphan_account
          UserMailer.deliver_related_work_notification(user, related_work)
        end
      end
    end
  end
end
