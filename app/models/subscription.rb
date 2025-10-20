class Subscription < ApplicationRecord
  VALID_SUBSCRIBABLES = %w(Work User Series).freeze

  belongs_to :user
  belongs_to :subscribable, polymorphic: true

  validates_presence_of :user

  validates :subscribable_type, inclusion: { in: VALID_SUBSCRIBABLES }
  # Without the condition, you get a 500 error instead of a validation error
  # if there's an invalid subscribable type
  validates :subscribable, presence: true,
                           if: proc { |s| VALID_SUBSCRIBABLES.include?(s.subscribable_type) }
  validate :subscribable_not_orphan
  # Get the subscriptions associated with this work
  # currently: users subscribed to work, users subscribed to creator of work
  # excludes: subscriptions to the orphan_account
  scope :for_work, lambda {|work|
    where(["(subscribable_id = ? AND subscribable_type = 'Work')
            OR (subscribable_id IN (?) AND subscribable_type = 'User')
            OR (subscribable_id IN (?) AND subscribable_type = 'Series')",
            work.id,
            work.pseuds.pluck(:user_id),
            work.serial_works.pluck(:series_id)]).
    group(:user_id)
  }

  # The name of the object to which the user is subscribed
  def name
    if subscribable.respond_to?(:login)
      subscribable.login
    elsif subscribable.respond_to?(:name)
      subscribable.name
    elsif subscribable.respond_to?(:title)
      subscribable.title
    else
      I18n.t("subscriptions.deleted")
    end
  end

  # Guard against scenarios that may break anonymity or other things.
  # Emails should only contain works or chapters.
  # Emails should only contain posted works or chapters.
  # Emails should never contain chapters of draft works.
  # Emails should never contain hidden works or chapters of hidden works.
  # Emails should never contain orphaned works or chapters.
  # TODO: AO3-3620 & AO3-5696: Allow subscriptions to orphan_account to receive notifications.
  # Emails for user subs should never contain anon works or chapters.
  # Emails for work subs should never contain anything but chapters.
  # TODO: AO3-1250: Anon series subscription improvements
  def valid_notification_entry?(creation)
    return false unless creation.is_a?(Chapter) || creation.is_a?(Work)
    return false unless creation.try(:posted)
    return false if creation.is_a?(Chapter) && !creation.work.try(:posted)
    return false if creation.try(:hidden_by_admin) || (creation.is_a?(Chapter) && creation.work.try(:hidden_by_admin))
    return false if creation.pseuds.all? { |p| p.user == User.orphan_account }
    return false if subscribable_type == "User" && creation.anonymous?
    return false if subscribable_type == "Work" && !creation.is_a?(Chapter)

    true
  end

  # Prevent subscriptions to the orphan_account and creations with orphan_account as the only creator
  def subscribable_not_orphan
    case subscribable_type
    when "User"
      errors.add(:subscribable, "Sorry! You cannot subscribe to the orphan account.") if subscribable == User.orphan_account
    when "Work", "Series"
      if subscribable.respond_to?(:users)
        # Get all non-orphan users on this work/series
        non_orphan_users = subscribable.users.where.not(id: User.orphan_account.id)

        if non_orphan_users.empty?
          type_name = subscribable_type.downcase
          errors.add(:subscribable, "Sorry! You cannot subscribe to a #{type_name} which is owned only by the orphan account.")
        end
      end
    end
  end
end
