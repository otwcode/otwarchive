# LEGACY - will be removed after beta has been migrated and the migrations reset

class TagCategory < ActiveRecord::Base
  has_many :tags
  
end
