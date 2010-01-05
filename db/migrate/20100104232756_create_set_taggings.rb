class CreateSetTaggings < ActiveRecord::Migration
  def self.up
    create_table :set_taggings do |t|
      t.references :tag
      t.references :tag_set

      t.timestamps
    end
  end

  def self.down
    drop_table :set_taggings
  end
end
