class CreateTagSetAssociations < ActiveRecord::Migration
  def self.up
    create_table :tag_set_associations do |t|
      t.references :owned_tag_set
      t.references :tag
      t.references :parent_tag

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_set_associations
  end
end
