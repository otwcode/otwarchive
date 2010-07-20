class Skin < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  has_many :preferences

  named_scope :public_skins, :conditions => {:public => true}
  named_scope :approved_skins, :conditions => {:official => true, :public => true}
  named_scope :unapproved_skins, :conditions => {:public => true, :official => false}
end
