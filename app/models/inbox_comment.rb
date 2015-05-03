class InboxComment < ActiveRecord::Base
  validates_presence_of :user_id
  validates_presence_of :feedback_comment_id

  belongs_to :user
  belongs_to :feedback_comment, :class_name => 'Comment'

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
    { :order => 'created_at ' + (filters[:date] || 'DESC'),
      :conditions => {:read => read, :replied_to => replied_to},
      :include => [:feedback_comment => :pseud] }
  }

  scope :for_homepage, conditions: { read: false },
                       order: "created_at DESC",
                       limit: ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_ON_HOMEPAGE

  # Gets the number of unread comments
  def self.count_unread
    self.count(:conditions => {:read => false})
  end

  # Get only the comments with a feedback_comment that exists
  def self.with_feedback_comment
    # Get an array of the ids of inbox comments that have existing feedback_comments
    inbox_comments_with_feedback_comment = []
    find_each do |inbox_comment|
      unless inbox_comment.feedback_comment.nil? ||
             inbox_comment.feedback_comment.is_deleted?
        inbox_comments_with_feedback_comment << inbox_comment
      end
    end
    # Get the ActiveRecord Relation objects based on that array
    where(id: inbox_comments_with_feedback_comment)
  end
end