class RemoveDateFromWork < ActiveRecord::Migration
  def self.up
    remove_column :works, :date
  end

  def self.down
    add_column :works, :date, :datetime
  end
end
