class WorkObserver < ActiveRecord::Observer

  # Email a copy of the deleted work to all co-authors
  def before_destroy(work)
    if work.posted?
      users = work.pseuds.collect(&:user).uniq
      orphan_account = User.orphan_account
      unless users.blank?
        for user in users
          # Check to see if this work is being deleted by an Admin
          if User.current_user.is_a?(Admin)
            unless user == orphan_account
              # this has to use the synchronous version because the work is going to be destroyed
              UserMailer.admin_deleted_work_notification(user, work).deliver!
            end
          else
            unless user == orphan_account
              # this has to use the synchronous version because the work is going to be destroyed
              UserMailer.delete_work_notification(user, work).deliver!
            end
          end
        end
      end
    end
  end

end
