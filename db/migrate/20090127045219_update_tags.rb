class UpdateTags < ActiveRecord::Migration
  def self.up
    remove_column :tags, :wrangled
    ThinkingSphinx.deltas_enabled=false
    puts "deleting unused tags"
    Tagging.all {|t| t.delete_unused_tags}
  end

  def self.down
    add_column :tags, :wrangled, :boolean, :default => false, :null => false
  end
end
