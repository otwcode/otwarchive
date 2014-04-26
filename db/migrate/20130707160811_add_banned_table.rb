class AddBannedTable < ActiveRecord::Migration
  def change
    create_table :banned_values do |t|
      t.string :name
      t.integer :ban_type
      t.timestamps
    end
  end
end

