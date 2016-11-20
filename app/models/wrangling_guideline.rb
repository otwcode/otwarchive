class WranglingGuideline < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  acts_as_list

  validates_presence_of :content, :title
  validates_length_of :content, maximum: ArchiveConfig.CONTENT_MAX,
                                too_long: ts('cannot be more than %{max} characters long.', max: ArchiveConfig.CONTENT_MAX)

  def self.reorder(positions)
    SortableList.new(find(:all, order: 'position ASC')).reorder_list(positions)
  end
end
