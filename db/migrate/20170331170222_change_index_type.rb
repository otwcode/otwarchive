class ChangeIndexType < ActiveRecord::Migration
  def up
    change_column :readings, :id, :bigint
    change_column :taggings, :id, :bigint
    change_column :kudos, :id, :bigint
  end

  def down
  end
end
