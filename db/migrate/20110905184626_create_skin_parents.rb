class CreateSkinParents < ActiveRecord::Migration
  def self.up
    create_table :skin_parents do |t|
      t.integer :child_skin_id
      t.integer :parent_skin_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :skin_parents
  end
end
