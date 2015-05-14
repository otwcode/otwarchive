class Kudo < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :commentable, :polymorphic => true

  validate :cannot_be_author
  validate :guest_cannot_kudos_restricted_work

  validates_uniqueness_of :pseud_id,
    :scope => [:commentable_id, :commentable_type],
    :message => ts("^You have already left kudos here. :)"),
    :if => "!pseud.nil?"

  validates_uniqueness_of :ip_address,
    :scope => [:commentable_id, :commentable_type],
    :message => ts("^You have already left kudos here. :)"),
    :if => "!ip_address.blank?"

  scope :with_pseud, where("pseud_id IS NOT NULL")
  scope :by_guest, where("pseud_id IS NULL")

  # return either the name of the kudo-leaver or "guest"
  def name
    if self.pseud
      pseud.name
    else
      "guest"
    end
  end

  def dup?
    errors.values.to_s.match /already left kudos/
  end

  def cannot_be_author
    if pseud
      commentable = commentable_type.classify.constantize.
                    find_by_id(commentable_id)
      kudos_giver = User.find_by_id(pseud.user_id)
      if kudos_giver.is_author_of?(commentable)
        errors.add(:cannot_be_author,
                   ts("^You can't leave kudos on your own work."))
      end
    end
  end

  def guest_cannot_kudos_restricted_work
    commentable = commentable_type.classify.constantize.
                  find_by_id(commentable_id)
    if pseud.nil? && commentable.restricted?
      errors.add(:guest_on_restricted,
                 ts("^You can't leave guest kudos on a restricted work."))
    end
  end

  def creator_of_work?
    errors.values.to_s.match /your own work/
  end
end
