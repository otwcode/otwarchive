class ChangeIndexType < ActiveRecord::Migration
  def up
    change_column :readings, :id, "bigint NOT NULL AUTO_INCREMENT"
    change_column :taggings, :id, "bigint NOT NULL AUTO_INCREMENT"
    change_column :kudos, :id, "bigint NOT NULL AUTO_INCREMENT"
  end

  def down
  end
end
