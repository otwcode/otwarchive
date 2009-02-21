class UpdateTags < ActiveRecord::Migration
  def self.up
#    remove_column :tags, :wrangled #remove later. it's not hurting anything.
    Tag.reset_column_information
    ThinkingSphinx.deltas_enabled=false
    puts "resetting tag count and parents. deleting unused tags"
    Tag.all.each do |t|
      puts "." if t.id.modulo(100) == 0
      Tag.update_counters t.id, :taggings_count => -t.taggings_count
      Tag.update_counters t.id, :taggings_count => t.taggings.length
      t.add_fandom(t.fandom) if t.fandom
      t.add_media(t.media) if t.media
      if t.taggings.length == 0 && !t.merger_id && t.children.length == 0
        t.destroy
      end
    end
    puts "Updating common tags"
    Work.all.each do |work|
      puts "." if work.id.modulo(100) == 0
      work.update_common_tags
    end
    puts "Updating pairing character field"
    Pairing.all.each do |pairing|
      pairing.update_attribute(:has_characters, true) unless pairing.characters.blank?
    end

    ThinkingSphinx.deltas_enabled=true
  end

  def self.down
    add_column :tags, :wrangled, :boolean, :default => false, :null => false
  end
end
