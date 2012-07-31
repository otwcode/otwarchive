class ArchiveFaq < ActiveRecord::Base
  acts_as_list

  has_many :questions, :dependent => :destroy
  accepts_nested_attributes_for :questions, :reject_if => lambda { |a| a[:question].blank? }, :allow_destroy => true

  attr_protected :content_sanitizer_version

  # validates_presence_of :content
  # CONTENT HAS BEEN REPLACED WITH 'ANSWER' in the Questions Model
  # validates_length_of :content, :minimum => ArchiveConfig.CONTENT_MIN,
  #   :too_short => ts("must be at least %{min} letters long.", :min => ArchiveConfig.CONTENT_MIN)

  # validates_length_of :content, :maximum => ArchiveConfig.CONTENT_MAX,
  #   :too_long => ts("cannot be more than %{max} characters long.", :max => ArchiveConfig.CONTENT_MAX)
  #   :too_long => ts("cannot be more than %{max} characters long.", :max => ArchiveConfig.CONTENT_MAX)

  def self.reorder(positions)
    SortableList.new(self.find(:all, :order => 'position ASC')).reorder_list(positions)
  end

end