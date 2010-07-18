class Skin < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  has_many :preferences

  named_scope :public_skins, :conditions => {:public => true}
end
