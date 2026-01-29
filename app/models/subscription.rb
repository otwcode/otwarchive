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
    else
      I18n.t("subscriptions.deleted")
    end
  end

  def creator_no_longer_associated_with?(creation)
    # If we're subscribed to a work or series, it doesn't matter who the creator is, we should send the notification
    return false unless subscribable_type == "User"

    # If any of the creation's pseud's users matches the subscribable, then the
    # creator still matches, so we return "true"
    return false if creation.pseuds.any? { |p| p.user == subscribable }

    # We reach this case if e.g. someone is subscribed to a user, but they
    # orphan the work before the subscription notification would be sent
    true
  end

  # Guard against scenarios that may break anonymity or other things.
  # Emails should only contain works or chapters.
  # Emails should only contain posted works or chapters.
  # Emails should never contain chapters of draft works.
  # Emails should never contain hidden works or chapters of hidden works.
  # Emails should not contain orphaned works or chapters if the subscription is to a creator no longer associated with the work
  # Emails for user subs should never contain anon works or chapters.
  # Emails for work subs should never contain anything but chapters.
  # TODO: AO3-1250: Anon series subscription improvements
  def valid_notification_entry?(creation)
    return false unless creation.is_a?(Chapter) || creation.is_a?(Work)
    return false unless creation.try(:posted)
    return false if creation.is_a?(Chapter) && !creation.work.try(:posted)
    return false if creation.try(:hidden_by_admin) || (creation.is_a?(Chapter) && creation.work.try(:hidden_by_admin))
    return false if creator_no_longer_associated_with?(creation)
    return false if subscribable_type == "User" && creation.anonymous?
    return false if subscribable_type == "Work" && !creation.is_a?(Chapter)

    true
  end
end
