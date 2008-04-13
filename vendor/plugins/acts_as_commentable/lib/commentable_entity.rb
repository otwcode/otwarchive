module CommentableEntity     
  
  def self.included(commentable)
    commentable.class_eval do      
      has_many :comments, :as => :commentable
      extend ClassMethods
    end
  end
  
  module ClassMethods
  end

  # Returns comments made directly to the commentable item
  def find_direct_comments
    commentable_type = self.class.to_s
    Comment.find(:all, :conditions => "commentable_type = '#{commentable_type}' and commentable_id = #{self.id}", :order => "created_at")
  end

  # Returns all comments
  def find_all_comments
    direct_comments = self.find_direct_comments
    @comments = []
    for comment in direct_comments
      @comments += comment.full_set
    end
    @comments
  end

  # Returns the total number of comments
  def count_all_comments
    direct_comments = self.find_direct_comments
    direct_comments.length + direct_comments.collect { |comment| comment.children_count }
  end  
   
end