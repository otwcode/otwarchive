class CreateTagNominations < ActiveRecord::Migration
  def self.up
    create_table :tag_nominations do |t|
      t.string :type
      t.references :tag_set_nomination
      t.references :fandom_nomination
      t.string :tagname
      t.string :parent_tagname
      t.text :tagnotes
      t.boolean :approved, :default => false, :null => false
      t.boolean :rejected, :default => false, :null => false
      t.boolean :wrangled, :default => false, :null => false
      t.boolean :ignored, :default => false, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_nominations
  end
end
