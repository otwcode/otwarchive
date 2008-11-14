class Beer < ActiveRecord::Base

  has_and_belongs_to_many :drunkards
  
end
