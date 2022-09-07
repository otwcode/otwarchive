class Kudo < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection
  include Responder

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validate :cannot_be_author
  validate :guest_cannot_kudos_restricted_work

  validates_uniqueness_of :ip_address,
                          scope: [:commentable_id, :commentable_type],
                          message: ts("^You have already left kudos here. :)"),
                          if: proc { |kudo| !kudo.ip_address.blank? }

  validates_uniqueness_of :user_id,
                          scope: [:commentable_id, :commentable_type],
                          message: ts("^You have already left kudos here. :)"),
                          if: proc { |kudo| !kudo.user.nil? }

  scope :with_user, -> { where("user_id IS NOT NULL") }
  scope :by_guest, -> { where("user_id IS NULL") }

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

  # Return either the name of the kudo-giver or "guest".
  # Used in kudo notifications.
  def name
    if self.user
      user.login
    else
      "guest"
    end
  end

  def dup?
    errors.values.to_s.match /already left kudos/
  end

  def cannot_be_author
    return unless user

    commentable = nil
    if commentable_type == "Work"
      commentable = Work.find_by(id: commentable_id)
    elsif commentable_type == "Chapter"
      commentable = Chapter.find_by(id: commentable_id).work
    end

    if commentable.nil?
      errors.add(:no_commentable,
                 ts("^What did you want to leave kudos on?"))
    elsif user.is_author_of?(commentable)
      errors.add(:cannot_be_author,
                 ts("^You can't leave kudos on your own work."))
    end
  end

  def guest_cannot_kudos_restricted_work
    return if user

    commentable = nil
    if commentable_type == "Work"
      commentable = Work.find_by(id: commentable_id)
    elsif commentable_type == "Chapter"
      commentable = Chapter.find_by(id: commentable_id).work
    end

    if commentable.nil?
      errors.add(:no_commentable,
                 ts("^What did you want to leave kudos on?"))
    elsif commentable.restricted?
      errors.add(:guest_on_restricted,
                 ts("^You can't leave guest kudos on a restricted work."))
    end
  end

  def creator_of_work?
    errors.values.to_s.match /your own work/
  end
end
