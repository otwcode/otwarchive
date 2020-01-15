class AddUserIdToKudos < ActiveRecord::Migration[5.1]
  def change
    add_column :kudos, :user_id, :int
    add_index :kudos, :user_id
  end
end
