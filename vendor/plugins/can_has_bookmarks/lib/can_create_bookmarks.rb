module CanCreateBookmarks     
  
	# Adds the "has_many" line to the appropriate model
  def self.included(bookmarkable)
    bookmarkable.class_eval do      
      has_many :bookmarks
    end
  end
	
	# Gets the number of public bookmarks
	def public_bookmark_count
		self.bookmarks.count(:all, :conditions => 'private IS NULL OR private = 0')
	end
	
	# Gets the total number of bookmarks, public and private
	def total_bookmark_count
		self.bookmarks.count
	end
	
end