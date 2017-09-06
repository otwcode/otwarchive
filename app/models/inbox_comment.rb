class InboxComment < ApplicationRecord
  validates_presence_of :user_id
  validates_presence_of :feedback_comment_id

  belongs_to :user
  belongs_to :feedback_comment, class_name: 'Comment'

  # Filters inbox comments by read and/or replied to and sorts by date
  scope :find_by_filters, lambda { |filters|
    read = case filters[:read]
      when 'true' then true
      when 'false' then false
      else [true, false]
    end
    replied_to = case filters[:replied_to]
      when 'true' then true
      when 'false' then false
      else [true, false]
    end

    includes(feedback_comment: :pseud)
    .order("created_at #{filters[:date] || 'DESC'}")
    .where(read: read, replied_to: replied_to)
  }

  scope :for_homepage, -> {
    where(read: false)
    .order(created_at: :desc)
    .limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_ON_HOMEPAGE)
  }

  # Gets the number of unread comments
  def self.count_unread
    where(read: false).count
  end

  # Get only the comments with a feedback_comment that exists
  def self.with_feedback_comment
    joins("LEFT JOIN comments ON comments.id = inbox_comments.feedback_comment_id").
    where("comments.id IS NOT NULL AND comments.is_deleted = 0")
  end
end
