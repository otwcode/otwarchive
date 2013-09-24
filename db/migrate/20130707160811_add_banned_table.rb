class AddBannedTable < ActiveRecord::Migration
  def change
    create_table :banned_value do |t|
      t.string :name
      t.integer :type
      t.timestamps
    end
  end
end

