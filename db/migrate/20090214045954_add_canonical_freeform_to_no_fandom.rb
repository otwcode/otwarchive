class AddCanonicalFreeformToNoFandom < ActiveRecord::Migration
  def self.up
    Tag.reset_column_information
    nofandom = Fandom.find_by_name(ArchiveConfig.FANDOM_NO_TAG_NAME)
    nofandom = Fandom.create(:name => ArchiveConfig.FANDOM_NO_TAG_NAME) unless nofandom

    Freeform.canonical.each do |tag|
      tag.update_attribute(:fandom_id, nofandom.id) unless tag.fandom_id
    end
  end

  def self.down
  end
end
