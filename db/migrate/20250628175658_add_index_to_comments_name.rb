class AddIndexToCommentsName < ActiveRecord::Migration[7.1]
  def change
    add_index :comments, :name
  end
end
