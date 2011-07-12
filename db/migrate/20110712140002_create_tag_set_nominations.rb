class CreateTagSetNominations < ActiveRecord::Migration
  def self.up
    create_table :tag_set_nominations do |t|
      t.references :pseud
      t.references :owned_tag_set
      t.string :fandom_nominations
      t.string :character_nominations
      t.string :relationship_nominations
      t.string :freeform_nominations
      t.string :fandom_nominations_notes
      t.string :character_nominations_notes
      t.string :relationship_nominations_notes
      t.string :freeform_nominations_notes

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_set_nominations
  end
end
