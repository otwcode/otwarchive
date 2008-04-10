class Work < ActiveRecord::Base
  has_many :chapters
  has_one :metadata, :as => :described
  validates_associated :chapters, :metadata
end
