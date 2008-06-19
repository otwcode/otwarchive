module HasBookmarks     
  
	# Adds the "has_many" line to the appropriate model
  def self.included(bookmarkable)
    bookmarkable.class_eval do      
      has_many :bookmarks, :as => :bookmarkable
    end
  end
	
	# Gets the number of public bookmarks for this object
	def public_bookmark_count
		self.bookmarks.count(:all, :conditions => 'private IS NULL OR private = 0')
	end
	
end