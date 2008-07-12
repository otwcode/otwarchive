class SerialWork < ActiveRecord::Base
  belongs_to :series
  belongs_to :work
  
  before_create :set_position
  
  # Sets the position of a work in a series
  def set_position
    self.position = self.series.serial_works.count + 1
  end
  
end
