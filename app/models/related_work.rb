class RelatedWork < ActiveRecord::Base
  belongs_to :work
  belongs_to :parent, :polymorphic => true
  
  scope :posted, joins(:work).where(works: { posted: true })

  def notify_parent_owners
    if parent.respond_to?(:pseuds)
      users = parent.pseuds.collect(&:user).uniq
      orphan_account = User.orphan_account
      users.each do |user|
        unless user == orphan_account
          UserMailer.related_work_notification(user.id, self.id).deliver
        end
      end
    end
  end

end
