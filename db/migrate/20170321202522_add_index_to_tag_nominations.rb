class AddIndexToTagNominations < ActiveRecord::Migration
  def change
    add_index :tag_nominations, :tagname
  end
end
