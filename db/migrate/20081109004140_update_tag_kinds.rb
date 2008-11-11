class UpdateTagKinds < ActiveRecord::Migration
  def self.up
    puts "Updating synonyms"
    synonym_pairs = TagRelationship.synonyms.collect{|r| [r.tag, r.related_tag]}
    all_synonymous = synonym_pairs.flatten.uniq.compact
    canonical_synonyms = all_synonymous & Tag.canonical
    canonical_synonyms.each do |canonical_tag|
      synonyms = []
      synonym_pairs.each do |array|
        synonyms << array[0] if array[1] == canonical_tag
        synonyms << array[1] if array[0] == canonical_tag
      end
      synonyms.each do |tag|
        tag.update_attribute('canonical_id', canonical_tag.id)
      end
    end

    puts "Updating media"
    category = TagCategory.find_by_name(ArchiveConfig.MEDIA_CATEGORY_NAME)
    category.tags.each do |media|
      media.tags.each { |fandom| fandom.update_attribute(:media_id, media.id) }
      media.update_attribute(:type, "Media")
    end if category
    puts "Updating fandoms"
    category = TagCategory.find_by_name(ArchiveConfig.FANDOM_CATEGORY_NAME)
    category.tags.each do |fandom|
      fandom.tags.each {|tag| tag.update_attribute(:fandom_id, fandom.id)}
      fandom.update_attribute(:type, "Fandom")
    end if category
    puts "Updating characters"
    category = TagCategory.find_by_name(ArchiveConfig.CHARACTER_CATEGORY_NAME)
    category.tags.each do |tag|
      tag.update_attribute(:type, "Character")
    end if category
    puts "Updating pairings"
    category = TagCategory.find_by_name(ArchiveConfig.PAIRING_CATEGORY_NAME)
    category.tags.each do |tag|
      tag.update_attribute(:type, "Pairing")
      Pairing.find(tag.id).update_characters
    end if category
    puts "Updating ratings"
    category = TagCategory.find_by_name(ArchiveConfig.RATING_CATEGORY_NAME)
    category.tags.each do |tag|
      tag.update_attribute(:type, "Rating")
    end if category
    puts "Updating warnings"
    category = TagCategory.find_by_name(ArchiveConfig.WARNING_CATEGORY_NAME)
    category.tags.each do |tag|
      tag.update_attribute(:type, "Warning")
    end if category
    puts "Updating categories"
    category = TagCategory.find_by_name(ArchiveConfig.CATEGORY_CATEGORY_NAME)
    category.tags.each do |tag|
      tag.update_attribute(:type, "Category")
    end if category
    puts "Updating freeform tags"
    category = TagCategory.find_by_name(ArchiveConfig.DEFAULT_CATEGORY_NAME)
    category.tags.each do |tag|
      tag.update_attribute(:type, "Freeform")
      first_work = tag.works.first
      fandom = first_work.fandoms.first if first_work
      tag.update_attribute(:fandom_id, fandom.id) if fandom
    end if category
  end

  def self.down
  end
end
