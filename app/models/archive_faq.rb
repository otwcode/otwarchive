class ArchiveFaq < ActiveRecord::Base
  acts_as_list

  has_many :questions, :dependent => :destroy
  accepts_nested_attributes_for :questions, :reject_if => lambda { |a| a[:question].blank? }, :allow_destroy => true

  attr_protected :content_sanitizer_version

  scope :non_translated, where('translated_faq_id IS NULL')

  def self.reorder(positions)
    SortableList.new(self.find(:all, :order => 'position ASC')).reorder_list(positions)
  end

end