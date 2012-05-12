class WorkObserver < ActiveRecord::Observer

  # TODO: Email a copy of the previous version of the work to all co-authors
  def before_update(work)
    #  users = work.pseuds.collect(&:user).uniq
    #	orphan_account = User.orphan_account
    #  unless users.blank?
    #    for user in users
    #      unless user.preference.edit_emails_off? || user == orphan_account
    #        UserMailer.edit_work_notification(user, work).deliver! 
    #      end
    #    end
    #  end
  end

  # Email a copy of the deleted work to all co-authors
  def before_destroy(work)
    if work.posted?
      users = work.pseuds.collect(&:user).uniq
      orphan_account = User.orphan_account
      unless users.blank?
        for user in users
          unless user == orphan_account
            # this has to use the synchronous version because the work is going to be destroyed
            UserMailer.delete_work_notification(user, work).deliver! 
          end
        end
      end
    end
  end

end
