class CreateTagSetNominations < ActiveRecord::Migration
  def self.up
    create_table :tag_set_nominations do |t|
      t.references :pseud
      t.references :owned_tag_set

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_set_nominations
  end
end
