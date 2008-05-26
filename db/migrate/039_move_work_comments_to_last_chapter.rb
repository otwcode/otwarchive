class MoveWorkCommentsToLastChapter < ActiveRecord::Migration
  def self.up
    Comment.find(:all, :conditions => "commentable_type = 'Work'").each do |comment|
      comment.commentable = comment.commentable.last_chapter
      comment.save!
    end
  end

  def self.down
  end
end
