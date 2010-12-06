class AddWorkSkinIdToWorks < ActiveRecord::Migration
  def self.up
    add_column :works, :work_skin_id, :integer
  end

  def self.down
    remove_column :works, :work_skin_id
  end
end
