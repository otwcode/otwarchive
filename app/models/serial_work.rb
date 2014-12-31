class SerialWork < ActiveRecord::Base
  belongs_to :series, :touch => true
  belongs_to :work, :touch => true
  validates_uniqueness_of :work_id, :scope => [:series_id]
  acts_as_list :scope => :series

  after_create :adjust_series_visibility
  after_destroy :adjust_series_visibility
  after_destroy :delete_empty_series

  scope :in_order, {:order => :position}

  # If you add or remove a work from a series, make sure restricted? is still accurate
  def adjust_series_visibility
    self.series.adjust_restricted unless self.series.blank?
  end

  # If you delete a work from a series and it was the last one, delete the series too
  def delete_empty_series
    if self.series.present? && self.series.serial_works.blank?
      self.series.destroy
    end
  end
end
