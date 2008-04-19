module CommentableEntity     
  
  def self.included(commentable)
    commentable.class_eval do      
      has_many :comments, :as => :commentable
      extend ClassMethods
    end
  end
  
  module ClassMethods
  end

  # Returns all comments
  def find_all_comments
    direct_comments = self.comments
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
    direct_comments = self.comments
    grandchildren = direct_comments.collect { |comment| comment.children_count }
    direct_comments.empty? ? 0 : direct_comments.length + grandchildren.sum
  end  
   
end