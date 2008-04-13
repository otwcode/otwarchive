class Comment < ActiveRecord::Base         
  belongs_to :pseud         
  belongs_to :commentable, :polymorphic => true
  acts_as_commentable
  
  validates_presence_of :content  
                             

    # Returns true if the comment is a reply to another comment                     
    def reply_comment?
      self.commentable_type == self.class.to_s
    end

    # Sets the depth value for threaded display purposes (higher depth value = more indenting)                     
    def set_depth
      if self.reply_comment?
        self.depth = self.commentable.depth + 1 
      else
        self.depth = 0
      end
    end     

    # Returns the total number of sub-comments
    def children_count
      if self.threaded_right
        return (self.threaded_right - self.threaded_left - 1)/2
      else
        return 0
      end
    end

    # Returns all sub-comments plus the comment itself 
    # Returns comment itself if unthreaded
    def full_set 
      if self.threaded_left
        Comment.find(:all, :conditions => ["threaded_left BETWEEN (?) and (?)", self.threaded_left, self.threaded_right])
      else
        return [self]
      end
    end

    # Returns all sub-comments
    def all_children
      Comment.find(:all, :conditions => "(threaded_left > #{self.threaded_left}) and (threaded_right < #{self.threaded_right})" )
    end             

    # Adds a child to this object in the tree. This method will update all of the
    # other elements in the tree and shift them to the right, keeping everything
    # balanced. 
    def add_child( child )
      #self.reload
      #child.reload

      if ( (self.threaded_left == nil) || (self.threaded_right == nil) )
        # Looks like we're now the root node!  Woo
        self.threaded_left = 1
        self.threaded_right = 4

        # What do to do about validation?
        return nil unless self.save

        child.commentable_id = self.id
        child.threaded_left = 2
        child.threaded_right= 3
        return child.save
      else
        # OK, we need to add and shift everything else to the right
        child.commentable_id = self.id
        right_bound = self.threaded_right
        child.threaded_left = right_bound
        child.threaded_right = right_bound + 1
        self.threaded_right += 2
        Comment.transaction {
          Comment.update_all( "threaded_left = (threaded_left + 2)",  "threaded_left >= #{right_bound}" )
          Comment.update_all( "threaded_right = (threaded_right + 2)",  "threaded_right >= #{right_bound}" )
          self.save
          child.save
        }
      end
    end

  end