class BuildInbox < ActiveRecord::Migration
  def self.up
    Comment.all.each do |comment|
      if comment.reply_comment?
        users = [comment.commentable.pseud.user] unless comment.commentable.pseud.blank? 
      else
        users = comment.commentable.respond_to?(:pseuds) ? comment.commentable.pseuds.collect(&:user) : [comment.commentable.user]
      end
      users.each do |user|  
        new_feedback = user.inbox_comments.build
        new_feedback.feedback_comment_id = comment.id
        new_feedback.save
      end
    end
  end

  def self.down
  end
end
