class AddRequiredTags < ActiveRecord::Migration
  def self.up
    works = Work.posted.reject { |w| w.has_required_tags? }
    for work in works
      if work.tags.by_category(TagCategory::RATING).blank?
        work.tags << Tag::DEFAULT_RATING_TAG
      end
      if work.tags.by_category(TagCategory::WARNING).blank?
        work.tags << Tag::DEFAULT_WARNING_TAG
      end      
    end
  end

  def self.down
  end
end
