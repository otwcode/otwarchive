class SerialWork < ActiveRecord::Base
  belongs_to :series
  belongs_to :work
  validates_uniqueness_of :work_id, :scope => [:series_id]
  acts_as_list :scope => :series
  
  before_create :adjust_series_visibility
  after_destroy :adjust_series_visibility
  
  named_scope :in_order, {:order => :position}
  
	# If you add or remove a work from a series, make sure restricted? is still accurate
  def adjust_series_visibility
    self.series.adjust_restricted
  end
  
end