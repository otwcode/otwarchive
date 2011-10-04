class CreateSkinParents < ActiveRecord::Migration
  def self.up
    create_table :skin_parents do |t|
      t.references :skin
      t.integer :skin_parent_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :skin_parents
  end
end
