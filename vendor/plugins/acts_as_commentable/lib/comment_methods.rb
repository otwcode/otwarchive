module CommentMethods
  
  def self.included(comment)
    comment.class_eval do      
      #extend ClassMethods
      include InstanceMethods
    end
  end 
  # 
  # module ClassMethods
  #   # Returns the last thread number assigned
  #   def max_thread
  #     Comment.maximum(:thread)
  #   end
  # end 

  module InstanceMethods      
    
    # Gets the object (chapter, bookmark, etc.) that the comment ultimately belongs to
    def ultimate_parent
      self.parent
    end

    # gets the comment that is the parent of this thread
    def thread_parent
      self.reply_comment? ? self.commentable.thread_parent : self
    end
    
    # Only destroys childless comments, sets is_deleted to true for the rest
    def destroy_or_mark_deleted
      if self.children_count > 0 
        self.is_deleted = true
        self.content = "deleted comment" # wipe out the content
        self.save
      else
        self.destroy
      end  
    end
    
    # Returns true if the comment is a reply to another comment                     
    def reply_comment?
      self.commentable_type == self.class.to_s
    end

    # Returns the total number of sub-comments
    def children_count
      self.threaded_right ? (self.threaded_right - self.threaded_left - 1)/2 : 0
    end

    # Returns all sub-comments plus the comment itself 
    # Returns comment itself if unthreaded
    def full_set 
      if self.threaded_left
        Comment.find(:all, :conditions => ["threaded_left BETWEEN (?) and (?) AND thread = (?)", 
                            self.threaded_left, self.threaded_right, self.thread],
                            :include => :pseud, :order => "threaded_left")
      else
        return [self]
      end
    end

    # Returns all sub-comments
    def all_children
      self.children_count > 0 ? Comment.find(:all, 
                                             :conditions => ["threaded_left > (?) and threaded_right < (?) and thread = (?)", 
                                             self.threaded_left, self.threaded_right, self.thread],
                                             :order => "threaded_left", :include => :pseud) : []
    end

    # Returns a full comment thread
    def full_thread
      Comment.find(:all, :conditions => ["thread = (?)", self.thread], :order => "threaded_left")
    end
            

    # Adds a child to this object in the tree. This method will update all of the
    # other elements in the tree and shift them to the right, keeping everything
    # balanced. 
    def add_child( child )
      if ( (self.threaded_left == nil) || (self.threaded_right == nil) )
        # Looks like we're now the root node!  Woo
        self.threaded_left = 1
        self.threaded_right = 4

        # What do to do about validation?
        return nil unless self.save

        child.commentable_id = self.id
        child.threaded_left = 2
        child.threaded_right= 3
      else
        # OK, we need to add and shift everything else to the right
        child.commentable_id = self.id
        right_bound = self.threaded_right
        child.threaded_left = right_bound
        child.threaded_right = right_bound + 1
        self.threaded_right += 2
        # Updates all comments in the thread to set their relative positions
        Comment.transaction {
          Comment.update_all("threaded_left = (threaded_left + 2)", ["thread = (?) AND threaded_left >= (?)", self.thread, right_bound])
          Comment.update_all("threaded_right = (threaded_right + 2)",  ["thread = (?) AND threaded_right >= (?)", self.thread, right_bound])
          self.save
        }
      end
    end
    
    # Adjusts left and right threading counts when a comment is deleted
    # otherwise, children_count is wrong
    def before_destroy
      Comment.transaction {
        Comment.update_all("threaded_left = (threaded_left - 2)", ["thread = (?) AND threaded_left > (?)", self.thread, self.threaded_left])
        Comment.update_all("threaded_right = (threaded_right - 2)",  ["thread = (?) AND threaded_right > (?)", self.thread, self.threaded_right])
      }
    end     
  end
end