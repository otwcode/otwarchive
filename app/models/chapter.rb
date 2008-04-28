class Chapter < ActiveRecord::Base
  belongs_to :work
  acts_as_commentable

  # A chapter does NOT have to have a metadata, so we don't 
  # validate for its presence. ???
  has_one :metadata, :as => :described
  validates_associated :metadata, :message => nil

  validates_presence_of :content
  validates_length_of :content, :maximum=>16777215

  # Set the position if this isn't the first chapter
  def before_create
    if self.work.number_of_chapters
      self.position = self.work.number_of_chapters + 1
    end
  end

end
