class WranglingGuideline < ActiveRecord::Base
  acts_as_list

  attr_protected :content_sanitizer_version

  validates_presence_of :content, :title
  validates_length_of :content, :maximum => ArchiveConfig.CONTENT_MAX,
    :too_long => ts('cannot be more than %{max} characters long.', :max => ArchiveConfig.CONTENT_MAX)

  def self.reorder(positions)
    SortableList.new(self.find(:all, :order => 'position ASC')).reorder_list(positions)
  end

end