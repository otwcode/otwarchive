class UpdateTags < ActiveRecord::Migration
  def self.up
    remove_column :tags, :wrangled
    ThinkingSphinx.deltas_enabled=false
    puts "deleting unused tags"
    Tagging.all {|t| t.delete_unused_tags}
    puts "resetting tag count and parents"
    Tag.find(:all).each do |t|
      puts "." if t.id.modulo(100) == 0
      Tag.update_counters t.id, :taggings_count => -t.taggings_count
      Tag.update_counters t.id, :taggings_count => t.taggings.length
      t.add_fandom(t.fandom.id) if t.fandom
      t.add_media(t.media.id) if t.media
    end
    ThinkingSphinx.deltas_enabled=true
  end

  def self.down
    add_column :tags, :wrangled, :boolean, :default => false, :null => false
  end
end
