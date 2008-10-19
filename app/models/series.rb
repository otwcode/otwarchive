class Series < ActiveRecord::Base
  has_many :serial_works, :dependent => :destroy
  has_many :works, :through => :serial_works
  has_bookmarks
  
  validates_presence_of :title
  validates_length_of :title, 
    :minimum => ArchiveConfig.TITLE_MIN, :too_short=> "must be at least %d letters long."/ArchiveConfig.TITLE_MIN

  validates_length_of :title, 
    :maximum => ArchiveConfig.TITLE_MAX, :too_long=> "must be less than %d letters long."/ArchiveConfig.TITLE_MAX
    
  validates_length_of :summary, 
    :allow_blank => true, 
    :maximum => ArchiveConfig.SUMMARY_MAX, :too_long => "must be less than %d letters long.".t/ArchiveConfig.SUMMARY_MAX
    
  validates_length_of :notes, 
    :allow_blank => true, 
    :maximum => ArchiveConfig.NOTES_MAX, :too_long => "must be less than %d letters long.".t/ArchiveConfig.NOTES_MAX

  # return list of pseuds on this series
  def authors
    works.collect(&:pseuds).flatten.compact.uniq
  end
  
  # return list of users on this series
  def owners
    self.authors.collect(&:user)
  end

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
