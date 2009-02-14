class AddCanonicalFreeformToNoFandom < ActiveRecord::Migration
  def self.up
    Freeform.canonical.each do |tag|
      tag.update_attribute(:fandom_id, Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME).id) unless tag.fandom_id
    end
  end

  def self.down
  end
end
