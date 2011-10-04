class CreateOwnedSetTaggings < ActiveRecord::Migration
  def self.up
    create_table :owned_set_taggings do |t|
      t.references :owned_tag_set
      t.integer  "set_taggable_id"
      t.string   "set_taggable_type", :limit => 100

      t.timestamps
    end
  end

  def self.down
    drop_table :owned_set_taggings
  end
end
