class CreateTagSetNominations < ActiveRecord::Migration
  def self.up
    create_table :tag_set_nominations do |t|
      t.references :pseud
      t.references :owned_tag_set
      t.text :fandom_nominations
      t.text :fandom_nomination_medias
      t.text :character_nominations
      t.text :character_nomination_fandoms
      t.text :relationship_nominations
      t.text :relationship_nomination_fandoms
      t.text :freeform_nominations
      t.text :fandom_nomination_notes
      t.text :character_nomination_notes
      t.text :relationship_nomination_notes
      t.text :freeform_nomination_notes

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_set_nominations
  end
end
