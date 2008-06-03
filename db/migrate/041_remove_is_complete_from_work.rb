class RemoveIsCompleteFromWork < ActiveRecord::Migration
  def self.up
    remove_column(:works, :is_complete)
  end

  def self.down
    add_column :works, :is_complete, :boolean
  end
end
