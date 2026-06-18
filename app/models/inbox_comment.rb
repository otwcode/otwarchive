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
    direction = (filters[:date]&.upcase == "ASC" ? "created_at ASC" : "created_at DESC")

    # Eager-load the associations the inbox view touches for each
    # feedback_comment, to avoid N+1 queries while rendering:
    #   pseud.user.official       -> user roles
    #   blocked_by? checks        -> user/work_creators' block_of_current_user
    #   commenter icon            -> pseud icon attachment
    #   commentable link/title    -> parent (and parent.work for chapters)
    includes(
      feedback_comment: [
        { pseud: [
          { user: %i[roles block_of_current_user] },
          { icon_attachment: :blob }
        ] },
        { parent: { work: { users: :block_of_current_user } } }
      ]
    ).
      order(direction).
      where(read: read, replied_to: replied_to)
  }

  scope :for_homepage, -> {
    where(read: false).
      order(created_at: :desc).
      limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_ON_HOMEPAGE)
  }

  # Gets the number of unread comments
  def self.count_unread
    where(read: false).count
  end

  # Remove comments that do not exist, were flagged as spam, or hidden by admin
  def self.with_bad_comments_removed
    joins("LEFT JOIN comments ON comments.id = inbox_comments.feedback_comment_id")
      .where("comments.id IS NOT NULL AND comments.is_deleted = 0 AND comments.approved AND NOT comments.hidden_by_admin")
  end
end
