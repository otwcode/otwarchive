class SerialWork < ActiveRecord::Base
  belongs_to :series
  belongs_to :work
  validates_uniqueness_of :work_id, :scope => [:series_id]
  
  before_create :set_position
  before_destroy :adjust_positions, :adjust_series_visibility
  
  # Sets the position of a work in a series
  def set_position
    self.position = self.series.serial_works.count + 1
  end
  
  # Adjust positions of other serial works down when one is deleted
  def adjust_positions
    serials = self.series.serial_works.find(:all, :conditions => "position > #{self.position}")
    serials.each {|s| s.update_attribute(:position, (s.position - 1))}
  end
  
  def adjust_series_visibility
    is_restricted = true
    self.series.works.each do |w|
      is_restricted = false if ((w.id != work.id) && w.posted && !w.restricted)
    end
    self.series.update_attribute(:restricted, is_restricted)
  end
  
end
