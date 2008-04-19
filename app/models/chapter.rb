class Chapter < ActiveRecord::Base
  belongs_to :work
  has_one :metadata, :as => :described
  acts_as_commentable

  validates_length_of :content, :maximum=>16777215

  # Set the position if this isn't the first chapter
  def before_create
    if self.work.number_of_chapters
      self.position = self.work.number_of_chapters + 1
    end
  end

end
