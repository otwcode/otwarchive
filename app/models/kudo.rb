class Kudo < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection
  include Responder

  belongs_to :pseud
  belongs_to :commentable, polymorphic: true

  validate :cannot_be_author
  validate :guest_cannot_kudos_restricted_work

  validates_uniqueness_of :pseud_id,
    scope: [:commentable_id, :commentable_type],
    message: ts("^You have already left kudos here. :)"),
    if: Proc.new { |kudo| !kudo.pseud.nil? }

  validates_uniqueness_of :ip_address,
    scope: [:commentable_id, :commentable_type],
    message: ts("^You have already left kudos here. :)"),
    if: Proc.new { |kudo| !kudo.ip_address.blank? }

  scope :with_pseud, -> { where("pseud_id IS NOT NULL") }
  scope :by_guest, -> { where("pseud_id IS NULL") }

  after_destroy :update_work_stats
  after_create :after_create, :update_work_stats
  def after_create
    users = self.commentable.pseuds.map(&:user).uniq

    users.each do |user|
      if notify_user_by_email?(user)
        RedisMailQueue.queue_kudo(user, self)
      end
    end
  end

  def notify_user_by_email?(user)
    user.nil? ? false : ( user.is_a?(Admin) ? true :
      !(user == User.orphan_account || user.preference.kudos_emails_off?) )
  end

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
       commentable = Work.find_by(id: commentable_id)
      end
      if commentable_type == "Chapter"
       commentable = Chapter.find_by(id: commentable_id).work
      end
      kudos_giver = User.find_by(id: pseud.user_id)
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
      commentable = Work.find_by(id: commentable_id)
    end
    if commentable_type == "Chapter"
      commentable = Chapter.find_by(id: commentable_id).work
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
