class ArchiveFaq < ActiveRecord::Base
  acts_as_list

  attr_protected :content_sanitizer_version
  before_save :update_sanitizer_version
  def update_sanitizer_version
    content_sanitizer_version = ArchiveConfig.SANITIZER_VERSION
  end
  
  validates_presence_of :content
  validates_length_of :content, :minimum => ArchiveConfig.CONTENT_MIN, 
    :too_short => t('content_too_short', :default => "must be at least %{min} letters long.", :min => ArchiveConfig.CONTENT_MIN)

  validates_length_of :content, :maximum => ArchiveConfig.CONTENT_MAX, 
    :too_long => t('content_too_long', :default => "cannot be more than %{max} characters long.", :max => ArchiveConfig.CONTENT_MAX)
    
  def self.reorder(positions)
    SortableList.new(self.find(:all, :order => 'position ASC')).reorder_list(positions)
  end

end