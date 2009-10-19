class Admin < ActiveRecord::Base
  acts_as_authentable(false)
  
  has_many :log_items
  has_many :invitations, :as => :creator
end
