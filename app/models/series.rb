class Series < ActiveRecord::Base
  has_many :serial_works, :dependent => :destroy
  has_many :works, :through => :serial_works
  has_bookmarks
  
  validates_presence_of :title
  validates_length_of :title, :within => ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX, :message => "must be within #{ArchiveConfig.TITLE_MIN} and #{ArchiveConfig.TITLE_MAX} letters long.".t
  validates_length_of :summary, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX, :too_long => "must be less than %d letters long."/ArchiveConfig.SUMMARY_MAX
  validates_length_of :notes, :allow_blank => true, :maximum => ArchiveConfig.NOTES_MAX, :too_long => "must be less than %d letters long."/ArchiveConfig.NOTES_MAX
end
