module CommentableEntity     
  
  def self.included(commentable)
    commentable.class_eval do      
      has_many :comments, :as => :commentable, :dependent => :destroy
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

  # These below have all been redefined to work for the archive
  
  # redefined for our archive to also not include 
  # hidden-by-admin comments.
  # returns number of visible (not deleted) comments
  def count_visible_comments
    self.find_all_comments.select {|c| !c.hidden_by_admin and !c.is_deleted }.length
  end  

  # Return the name of this commentable object
  # Should be overridden in the implementing class if necessary
  def commentable_name
    begin
      self.title
    rescue
      ""
    end
  end

  def commentable_owners
    begin
      self.pseuds.map {|p| p.user}.uniq
    rescue
      begin
        [self.pseud.user]
      rescue
        []
      end
    end
  end

  # Return the email to reach the owner of this commentable object
  # Should be overridden in the implementing class if necessary
  def commentable_owner_email
    if self.commentable_owners.empty?
      begin
        self.email
      rescue
        ""
      end
    else
      self.commentable_owners.email.join(',')
    end
  end
   
end