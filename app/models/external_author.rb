class ExternalAuthor < ActiveRecord::Base
  belongs_to :user
  
  has_many :external_author_names, :dependent => :destroy
  accepts_nested_attributes_for :external_author_names, :allow_destroy => true

  has_many :works, :through => :external_creatorships, :source => :creation, :source_type => 'Work', :uniq => true

  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true
  
end
