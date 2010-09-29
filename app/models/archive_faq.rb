class ArchiveFaq < ActiveRecord::Base
  include HtmlFormatter
  acts_as_list
  
  validates_presence_of :content
  validates_length_of :content, :minimum => ArchiveConfig.CONTENT_MIN, 
    :too_short => t('content_too_short', :default => "must be at least %{min} letters long.", :min => ArchiveConfig.CONTENT_MIN)

  validates_length_of :content, :maximum => ArchiveConfig.CONTENT_MAX, 
    :too_long => t('content_too_long', :default => "cannot be more than %{max} characters long.", :max => ArchiveConfig.CONTENT_MAX)
    
  def self.reorder(positions)
    SortableList.new(self.find(:all, :order => 'position ASC')).reorder_list(positions)
  end

end