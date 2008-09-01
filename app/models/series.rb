class Series < ActiveRecord::Base
  has_many :serial_works, :dependent => :destroy
  has_many :works, :through => :serial_works
  has_bookmarks
  
  validates_presence_of :title
  validates_length_of :title, :within => ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX, :message => "must be within".t + " #{ArchiveConfig.TITLE_MIN} " + "and".t + " #{ArchiveConfig.TITLE_MAX} " + "letters long.".t
  validates_length_of :summary, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX, :too_long => "must be less than %d letters long.".t/ArchiveConfig.SUMMARY_MAX
  validates_length_of :notes, :allow_blank => true, :maximum => ArchiveConfig.NOTES_MAX, :too_long => "must be less than %d letters long.".t/ArchiveConfig.NOTES_MAX

  def serials=(positions)
    self.reorder_works(positions)
  end
  
  # Reorders serial_works in series based on form data
	# Similar to reorder_chapters method in work.rb
  def reorder_works(positions)
    serials = self.serial_works.find(:all, :order => 'position')
    changed = {}
    positions.collect!(&:to_i).each_with_index do |new_position, old_position|
    	if new_position != 0 && new_position <= self.serial_works.count && !changed.has_key?(new_position)
    		changed.merge!({new_position => serials[old_position]})
    	end
    end
    serials -= changed.values
    changed.sort.each {|pair| pair.first > serials.length ? serials << pair.last : serials.insert(pair.first-1, pair.last)}
    serials.each_with_index {|serial, index| serial.update_attribute(:position, index + 1)}
  end

end
