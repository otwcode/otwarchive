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
    Comment.find(:all, :conditions => ["commentable_type = (?) and commentable_id = (?)", self.class.to_s, self.id], :order => "created_at")
  end

  # Returns all comments
  def find_all_comments
    direct_comments = self.find_direct_comments
    if direct_comments 
      @comments = []
      for comment in direct_comments
        @comments += comment.full_set
      end
      @comments
    end
  end

  # Returns the total number of comments
  def count_all_comments
    direct_comments = self.find_direct_comments
    grandchildren = direct_comments.collect { |comment| comment.children_count }
    direct_comments.empty? ? 0 : direct_comments.length + grandchildren.sum
  end  
   
end