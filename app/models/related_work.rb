class RelatedWork < ActiveRecord::Base 
  belongs_to :work
  belongs_to :parent, :polymorphic => true
  
  def notify_parent_owners
    if parent.respond_to?(:pseuds)
      users = parent.pseuds.collect(&:user).uniq
      orphan_account = User.orphan_account
      users.each do |user|
        unless user == orphan_account
          UserMailer.deliver_related_work_notification(user, self)
        end
      end
    end
  end
  
end