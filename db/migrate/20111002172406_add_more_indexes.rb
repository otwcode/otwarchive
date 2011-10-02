class AddMoreIndexes < ActiveRecord::Migration
  def self.up
    add_index "prompts", ["collection_id"]
  end

  def self.down
    remove_index "prompts", ["collection_id"]
  end
end
