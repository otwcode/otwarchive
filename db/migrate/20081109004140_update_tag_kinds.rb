class UpdateTagKinds < ActiveRecord::Migration
  def self.up

    puts "Updating media"
    tags = TagCategory.find_by_name("Media").andand.tags
    unless tags.blank?
      tags.each do |tag| 
        fandom_ids = tag.tags.map(&:id).join(",")
        unless fandom_ids.blank?
          execute "UPDATE tags SET media_id=#{tag.id} WHERE id IN (#{fandom_ids});" 
          execute "UPDATE tags SET wrangled=1 WHERE id IN (#{fandom_ids});" 
        end
      end
      tag_ids = tags.map(&:id).join(",") 
      execute "UPDATE tags SET type=\"Media\" WHERE id IN (#{tag_ids});"
    end
    
    puts "Updating fandoms"
    tags = TagCategory.find_by_name("Fandom").andand.tags
    unless tags.blank?
      puts "Updating fandom ids"
      tags.each do |tag| 
        child_ids = tag.tags.map(&:id).join(",") 
        execute "UPDATE tags SET fandom_id=#{tag.id} WHERE id IN (#{child_ids});" unless child_ids.blank?
      end
      tag_ids = tags.map(&:id).join(",") 
      execute "UPDATE tags SET type=\"Fandom\" WHERE id IN (#{tag_ids});"
      execute "UPDATE tags SET fandom_id = NULL WHERE id IN (#{tag_ids});"
    end
    
    puts "Updating characters"
    tags = TagCategory.find_by_name("Character").andand.tags
    unless tags.blank?
      tag_ids = tags.map(&:id).join(",") 
      execute "UPDATE tags SET type=\"Character\" WHERE id IN (#{tag_ids});" 
    end
    
    puts "Updating pairings"
    tags = TagCategory.find_by_name("Pairing").andand.tags
    unless tags.blank?
      tag_ids = tags.map(&:id).join(",")
      execute "UPDATE tags SET type=\"Pairing\" WHERE id IN (#{tag_ids});"
      puts "Updating pairing children"
      tags.each do |tag|
        pairing = Pairing.find(tag.id)
        pairing.wrangle_characters(false)
      end
    end
    
    puts "Updating ratings"
    tags = TagCategory.find_by_name("Rating").andand.tags
    unless tags.blank?
      tag_ids = tags.map(&:id).join(",")
      execute "UPDATE tags SET type=\"Rating\" WHERE id IN (#{tag_ids});"
    end
    
    puts "Updating warnings"
    tags = TagCategory.find_by_name("Warning").andand.tags
    unless tags.blank?
      tag_ids = tags.map(&:id).join(",")
      execute "UPDATE tags SET type=\"Warning\" WHERE id IN (#{tag_ids});"
    end
      
    puts "Updating categories"
    tags = TagCategory.find_by_name("Category").andand.tags
    unless tags.blank?
      tag_ids = tags.map(&:id).join(",")
      execute "UPDATE tags SET type=\"Category\" WHERE id IN (#{tag_ids});"
    end
    
    puts "Updating freeform"
    tags = Legacy.all
    unless tags.blank?
      tag_ids = tags.map(&:id).join(",")
      execute "UPDATE tags SET type=\"Freeform\" WHERE id IN (#{tag_ids});"
    end
    
    puts "Updating mergers (previously synonyms)"
    # unfortunately, in the legacy database some synonyms went one way, 
    # and some went the other (they were supposed to go both)
    pairs = TagRelationship.synonyms.collect{|r| [r.tag, r.related_tag]}
    tags = pairs.flatten.uniq.compact
    canonical_tags = tags & Tag.canonical
    canonical_tags.each do |canonical_tag|
      mergers = []
      pairs.each do |array|
        mergers << array[0] if array[1] == canonical_tag
        mergers << array[1] if array[0] == canonical_tag
      end
      mergers.each { |tag| tag.wrangle_merger(canonical_tag, false) unless tag.canonical? }
    end
       
    puts "Updating common tags"
    Work.all.each do |work|
      puts "." if work.id.modulo(100) == 0
      work.update_common_tags
    end
  end

  def self.down
  end
end
