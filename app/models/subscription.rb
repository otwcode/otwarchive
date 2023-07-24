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
  
  # Get the subscriptions associated with this work
  # currently: users subscribed to work, users subscribed to creator of work
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
    end
  end

  # Guard against scenarios that may break anonymity or other things.
  # Emails should only contain works or chapters.
  # Emails should only contain posted works or chapters.
  # Emails should never contain chapters of draft works.
  # Emails should never contain orphaned works or chapters.
  # TODO: AO3-3620 & AO3-5696: Allow subscriptions to orphan_account to receive
  # notifications.
  # Emails for user subs should never contain anon works or chapters.
  # Emails for work subs should never contain anything but chapters.
  # Emails for subs to anon works or series should never contain non-anon works
  # or chapters, or vice versa.
  def valid_notification_entry?(creation)
    return false unless creation.is_a?(Chapter) || creation.is_a?(Work)
    return false unless creation.try(:posted)
    return false if creation.is_a?(Chapter) && !creation.work.try(:posted)
    return false if creation.pseuds.any? { |p| p.user == User.orphan_account }
    return false if subscribable_type == "User" && creation.anonymous?
    return false if subscribable_type == "Work" && !creation.is_a?(Chapter)
    return false if subscribable.respond_to?(:anonymous?) &&
                    subscribable.anonymous? != creation.anonymous?

    true
  end
end
