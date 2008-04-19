class Work < ActiveRecord::Base
  has_many :chapters, :dependent => :destroy
  has_one :metadata, :as => :described, :dependent => :destroy
  acts_as_commentable
  validates_associated :chapters, :metadata
  attr_reader :pseud 
  
  def number_of_chapters
     Chapter.maximum(:position, :conditions => ['work_id = ?', self.id])
  end 

end
