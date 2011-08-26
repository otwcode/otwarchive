class AddSynonymToTagNominations < ActiveRecord::Migration
  def self.up
    add_column :tag_nominations, :synonym, :string
  end

  def self.down
    remove_column :tag_nominations, :synonym
  end
end
