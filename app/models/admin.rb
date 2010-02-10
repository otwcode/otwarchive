class Admin < ActiveRecord::Base
  acts_as_authentable(false)
  
  has_many :log_items
  has_many :invitations, :as => :creator
  has_many :wrangled_tags, :class_name => 'Tag', :as => :last_wrangler 
end
