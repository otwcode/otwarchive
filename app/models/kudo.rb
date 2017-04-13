class Kudo < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

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

  attr_accessible :commentable_id, :commentable_type

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
      commentable = nil
      if commentable_type == "Work" 
       commentable = Work.find_by_id(commentable_id)
      end
      if commentable_type == "Chapter"
       commentable = Chapter.find_by_id(commentable_id).work
      end
      kudos_giver = User.find_by_id(pseud.user_id)
      if commentable.nil? 
        errors.add(:no_commentable,
                   ts("^What did you want to leave kudos on?"))
      elsif kudos_giver.is_author_of?(commentable)
        errors.add(:cannot_be_author,
                   ts("^You can't leave kudos on your own work."))
      end
    end
  end

  def guest_cannot_kudos_restricted_work
    commentable = nil
    if commentable_type == "Work"
      commentable = Work.find_by_id(commentable_id)
    end
    if commentable_type == "Chapter"
      commentable = Chapter.find_by_id(commentable_id).work
    end
    if commentable.nil?
      errors.add(:no_commentable,
                 ts("^What did you want to leave kudos on?"))
    elsif pseud.nil? && commentable.restricted?
      errors.add(:guest_on_restricted,
                 ts("^You can't leave guest kudos on a restricted work."))
    end
  end

  def creator_of_work?
    errors.values.to_s.match /your own work/
  end
end
