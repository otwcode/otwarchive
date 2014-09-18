class Question < ActiveRecord::Base
  acts_as_list

  translates :question, :content
  #def update_sanitizer_version; end
  skip_callback :save, :before, :update_sanitizer_version
  belongs_to :archive_faq
  attr_protected :content_sanitizer_version
  attr_protected :screencast_sanitizer_version

  validates_presence_of :question, :before => :create
  validates_presence_of :anchor, :before => :create
  validates_presence_of :content, :before => :create

  validates_length_of :content, :minimum => ArchiveConfig.CONTENT_MIN,
                      :too_short => ts("must be at least %{min} letters long.", :min => ArchiveConfig.CONTENT_MIN)

  validates_length_of :content, :maximum => ArchiveConfig.CONTENT_MAX,
                      :too_long => ts("cannot be more than %{max} characters long.", :max => ArchiveConfig.CONTENT_MAX)

  def self.reorder(positions)
    SortableList.new(self.find(:all, :order => 'position ASC')).reorder_list(positions)
  end
end
