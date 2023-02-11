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
  
  # Get the subscriptions associated with this work.
  # These subscriptions are not unique per user: there are up to three, one per type.
  # This allows us to pick which one to keep by subscribable_type precedence later.
  scope :for_work_with_duplicates, lambda { |work|
    where(["(subscribable_id = ? AND subscribable_type = 'Work')
            OR (subscribable_id IN (?) AND subscribable_type = 'User')
            OR (subscribable_id IN (?) AND subscribable_type = 'Series')",
           work.id,
           work.pseuds.pluck(:user_id),
           work.serial_works.pluck(:series_id)])
      .group(:user_id, :subscribable_type)
  }

  # Prefer Work, then Series, then User type subscription
  def self.pick_most_relevant_of(user_subscriptions)
    # Skip ordering if there's only one in the list
    return user_subscriptions[0] if user_subscriptions.length == 1

    best_subscription = user_subscriptions[0]
    user_subscriptions.each do |subscription|
      # Return immediately if we find a "Work"-type subscription
      return subscription if subscription.subscribable_type == "Work"

      # Anything is better than a "User"-type subscription
      best_subscription = subscription if best_subscription.subscribable_type == "User"
    end
    best_subscription
  end

  def self.for_work(work)
    Subscription.for_work_with_duplicates(work).group_by(&:user_id).values
      .map { |subscriptions| Subscription.pick_most_relevant_of(subscriptions) }
  end

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

  def subject_text(creation)
    authors = if self.class.anonymous_creation?(creation)
                "Anonymous"
              else
                creation.pseuds.map(&:byline).to_sentence
              end
    chapter_text = creation.is_a?(Chapter) ? "#{creation.chapter_header} of " : ""
    work_title = creation.is_a?(Chapter) ? creation.work.title : creation.title
    text = "#{authors} posted #{chapter_text}#{work_title}"
    text += subscribable_type == "Series" ? " in the #{self.name} series" : ""
  end

  def self.anonymous_creation?(creation)
    (creation.is_a?(Work) && creation.anonymous?) || (creation.is_a?(Chapter) && creation.work.anonymous?)
  end
end
