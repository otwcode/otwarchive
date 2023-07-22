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

  def self.anonymous_creation?(creation)
    (creation.is_a?(Work) && creation.anonymous?) || (creation.is_a?(Chapter) && creation.work.anonymous?)
  end
end
