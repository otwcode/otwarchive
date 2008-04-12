# ActsAsBookmarkable
module Juixe
  module Acts #:nodoc:
    module Bookmarkable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_bookmarkable
          has_many :bookmarks, :as => :bookmarkable, :dependent => :destroy
          include Juixe::Acts::Bookmarkable::InstanceMethods
          extend Juixe::Acts::Bookmarkable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        # Helper class method to lookup comments for
        # the mixin commentable type written by a given user.  
        # This method is NOT equivalent to Bookmark.find_bookmarks_for_user
        def find_bookmarks_by_user(user) 
          bookmarkable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          
          Bookmark.find(:all,
            :conditions => ["user_id = ? and bookmarkable_type = ?", user.id, bookmarkable],
            :order => "created_at DESC"
          )
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        # Check to see if a user already bookmaked this bookmarkable
        def bookmarked_by_user?(user)
          rtn = false
          if user
            self.bookmarks.each { |b|
              rtn = true if user.id == b.user_id
            }
          end
          rtn
        end
      end
      
    end
  end
end
