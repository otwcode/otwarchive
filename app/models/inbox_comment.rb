class InboxComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :feedback_comment, :class_name => 'Comment'
end
