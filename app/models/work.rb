class Work < ActiveRecord::Base
  has_many :chapters
  after_update :save_chapters

  # create chapters using attributes submitted via form (or update them if they already exist)
  def chapter_attributes=(chapter_attributes)
    chapter_attributes.each do |attributes|
      if attributes[:id].blank?
        chapters.build(attributes)
      else
        chapter = chapters.detect { |t| t.id == attributes[:id].to_i }
        chapter.attributes = attributes
      end
    end
  end

  # callback to save all chapters after an update to work
  def save_chapters
    chapters.each do |c|
      # false => bypass validation, should be handled before!
      c.save(false)
    end
  end
end
