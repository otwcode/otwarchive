class UpdateTags < ActiveRecord::Migration
  def self.up
    remove_column :tags, :wrangled
    ThinkingSphinx.deltas_enabled=false
    puts "deleting unused tags"
    Tagging.all {|t| t.delete_unused_tags}
    puts "guessing character fandoms"
    Character.no_fandom.each do |tag|
      puts "." if tag.id.modulo(100) == 0
      tag.guess_fandom
    end
    puts "guessing pairing fandoms"
    Pairing.no_fandom.each do |tag|
      puts "." if tag.id.modulo(100) == 0
      tag.guess_fandom
    end
  end

  def self.down
    add_column :tags, :wrangled, :boolean, :default => false, :null => false
  end
end
