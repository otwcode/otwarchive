class UpdateTagKinds < ActiveRecord::Migration
  def self.up
    puts "Updating media"
      tags = TagCategory.find_by_name("Media").andand.tags
      tag_ids = tags.map(&:id).join(",") unless tags.blank?
      execute "UPDATE taggings SET tagger_type=\"Tag\" WHERE tagger_id IN (#{tag_ids});" unless tag_ids.blank?
      execute "UPDATE tags SET type=\"Media\" WHERE id IN (#{tag_ids});" unless tag_ids.blank?
      tags.each do |tag|
        related = tag.tags
        related_ids = related.map(&:id).join(",")
        execute "UPDATE tags SET media_id=#{tag.id} WHERE id IN (#{related_ids})" unless related_ids.blank?
      end unless tags.blank?
    puts "Updating fandoms"
      tags = TagCategory.find_by_name("Fandom").andand.tags
      tag_ids = tags.map(&:id).join(",") unless tags.blank?
      execute "UPDATE taggings SET tagger_type=\"Tag\" WHERE tagger_id IN (#{tag_ids});" unless tag_ids.blank?
      execute "UPDATE tags SET type=\"Fandom\" WHERE id IN (#{tag_ids});" unless tag_ids.blank?
      tags.each do |tag|
        related = tag.tags
        related_ids = related.map(&:id).join(",")
        execute "UPDATE tags SET fandom_id=#{tag.id} WHERE id IN (#{related_ids})" unless related_ids.blank?
      end unless tags.blank?
    puts "Updating characters"
      tags = TagCategory.find_by_name("Character").andand.tags
      tag_ids = tags.map(&:id).join(",") unless tags.blank?
      execute "UPDATE taggings SET tagger_type=\"Tag\" WHERE tagger_id IN (#{tag_ids});" unless tag_ids.blank?
      execute "UPDATE tags SET type=\"Character\" WHERE id IN (#{tag_ids});" unless tag_ids.blank?
      tags.each do |tag|
        fandom = tag.works.collect(&:canonical_fandom).flatten.first
        tag.update_attribute(:fandom_id, fandom.id) if fandom
      end unless tags.blank?
    puts "Updating pairings"
      tags = TagCategory.find_by_name("Pairing").andand.tags
      tag_ids = tags.map(&:id).join(",") unless tags.blank?
      execute "UPDATE taggings SET tagger_type=\"Tag\" WHERE tagger_id IN (#{tag_ids});" unless tag_ids.blank?
      execute "UPDATE tags SET type=\"Pairing\" WHERE id IN (#{tag_ids});" unless tag_ids.blank?
      tags.each do |tag|
        fandom = tag.works.collect(&:canonical_fandom).flatten.first
        tag.update_attribute(:fandom_id, fandom.id) if fandom
        Pairing.find(tag.id).update_characters
      end unless tags.blank?
    puts "Updating ratings"
      tags = TagCategory.find_by_name("Rating").andand.tags
      tag_ids = tags.map(&:id).join(",") unless tags.blank?
      execute "UPDATE taggings SET tagger_type=\"Tag\" WHERE tagger_id IN (#{tag_ids});" unless tag_ids.blank?
      execute "UPDATE tags SET type=\"Rating\" WHERE id IN (#{tag_ids});" unless tag_ids.blank?
    puts "Updating warnings"
      tags = TagCategory.find_by_name("Warning").andand.tags
      tag_ids = tags.map(&:id).join(",") unless tags.blank?
      execute "UPDATE taggings SET tagger_type=\"Tag\" WHERE tagger_id IN (#{tag_ids});" unless tag_ids.blank?
      execute "UPDATE tags SET type=\"Warning\" WHERE id IN (#{tag_ids});" unless tag_ids.blank?
    puts "Updating categories"
      tags = TagCategory.find_by_name("Category").andand.tags
      tag_ids = tags.map(&:id).join(",") unless tags.blank?
      execute "UPDATE taggings SET tagger_type=\"Tag\" WHERE tagger_id IN (#{tag_ids});" unless tag_ids.blank?
      execute "UPDATE tags SET type=\"Category\" WHERE id IN (#{tag_ids});" unless tag_ids.blank?
    puts "Updating freeform"
      tags = Legacy.all
      tag_ids = tags.map(&:id).join(",") unless tags.blank?
      execute "UPDATE taggings SET tagger_type=\"Tag\" WHERE tagger_id IN (#{tag_ids});" unless tag_ids.blank?
      execute "UPDATE tags SET type=\"Freeform\" WHERE id IN (#{tag_ids});" unless tag_ids.blank?
      tags.each do |tag|
        fandom = tag.works.collect(&:canonical_fandom).flatten.first
        tag.update_attribute(:fandom_id, fandom.id) if fandom
      end unless tags.blank?
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
        if canonical_tag.is_a?(Freeform)
          genre_tag = Genre.create_from_freeform(canonical_tag)
          synonyms.each { |tag| tag.add_to_genre(genre_tag) }
        else
          synonyms.each { |tag| tag.update_attribute('canonical_id', canonical_tag.id) }
        end
      end
  end

  def self.down
  end
end
