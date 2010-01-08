module CommentableEntity     
  
  def self.included(commentable)
    commentable.class_eval do      
      has_many :comments, :as => :commentable, :dependent => :destroy
      has_many :total_comments, :class_name => 'Comment', :as => :parent 
      extend ClassMethods
    end
  end
  
  module ClassMethods
  end

  # Returns all comments
  def find_all_comments
    self.total_comments.find(:all, :order => 'thread, threaded_left')
  end

  # Returns the total number of comments
  def count_all_comments
    self.total_comments.count
  end

  # These below have all been redefined to work for the archive
  
  # redefined for our archive to also not include 
  # hidden-by-admin comments.
  # returns number of visible (not deleted) comments
  def count_visible_comments
    self.total_comments.count(:all, :conditions => {:hidden_by_admin => false, :is_deleted => false})
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