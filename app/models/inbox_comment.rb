class InboxComment < ActiveRecord::Base
  validates_presence_of :user_id
  validates_presence_of :feedback_comment_id
	
  belongs_to :user
  belongs_to :feedback_comment, :class_name => 'Comment'
end
