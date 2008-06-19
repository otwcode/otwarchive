module CanHasBookmarks
	def self.included(base) # :nodoc:
		base.extend ClassMethods
	end  
	
	module ClassMethods
		def has_bookmarks
			send :include, HasBookmarks
		end
		
		def can_create_bookmarks
			send :include, CanCreateBookmarks
		end    
	end   
end
