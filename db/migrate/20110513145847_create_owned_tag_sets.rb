class CreateOwnedTagSets < ActiveRecord::Migration
  def self.up
    create_table :owned_tag_sets do |t|
      t.references :tag_set
      t.boolean :visible, :default => false, :null => false
      t.boolean :nominated, :default => false, :null => false
      t.string :title
      t.string :description

      t.timestamps
    end

    create_table :tag_set_ownerships do |t|
      t.references :pseud
      t.references :owned_tag_set
      t.boolean :owner, :default => false, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_set_ownerships
    drop_table :owned_tag_sets    
  end
end
