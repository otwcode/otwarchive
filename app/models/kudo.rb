class Kudo < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection
  include Responder

  VALID_COMMENTABLE_TYPES = %w[Work].freeze

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :commentable_type, inclusion: { in: VALID_COMMENTABLE_TYPES }
  validates :commentable,
            presence: true,
            if: proc { |c| VALID_COMMENTABLE_TYPES.include?(c.commentable_type) }

  validate :cannot_be_author
  def cannot_be_author
    return unless user&.is_author_of?(commentable)

    errors.add(:commentable, :author_on_own_work)
  end

  validate :guest_cannot_kudos_restricted_work
  def guest_cannot_kudos_restricted_work
    return unless user.blank? && commentable.is_a?(Work) && commentable.restricted?

    errors.add(:commentable, :guest_on_restricted)
  end

  validates :ip_address,
            uniqueness: { scope: [:commentable_id, :commentable_type], case_sensitive: false },
            if: proc { |kudo| kudo.ip_address.present? }

  validates :user_id,
            uniqueness: { scope: [:commentable_id, :commentable_type], case_sensitive: false },
            if: proc { |kudo| kudo.user.present? }

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
end
