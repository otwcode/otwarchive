# Include hook code here
require 'acts_as_bookmarkable'
ActiveRecord::Base.send(:include, Juixe::Acts::Bookmarkable)
