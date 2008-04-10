class Work < ActiveRecord::Base
  has_many :chapters
  has_one :metadata, :as => :described
  after_update :save_chapters, :save_metadata

  # create/update metadata
  def metadata_attributes=(metadata_attributes)
    if metadata_attributes[:id].blank?
      create_metadata(metadata_attributes)
    else
      metadata.attributes = metadata_attributes
    end
  end

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

  # callbac function to save metadata after update
  def save_metadata
    metadata.save
  end

  # callback to save all chapters after an update to work
  def save_chapters
    chapters.each do |c|
      # false => bypass validation, should be handled before!
      c.save(false)
    end
  end
end
