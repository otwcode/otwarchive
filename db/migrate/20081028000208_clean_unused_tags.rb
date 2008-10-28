class CleanUnusedTags < ActiveRecord::Migration
  def self.up
    Tag.all.each do |tag|
      unless tag.taggings.count > 0 || Tag::PREDEFINED_TAGS.include?(tag) || tag.tags.count > 0 || tag.related_tags.count > 0
        tag.destroy
      end
    end
  end

  def self.down
  end
end
