class AddDefaultValueToExpectedNumberOfChapters < ActiveRecord::Migration
  def self.up
    change_column :works, :expected_number_of_chapters, :integer, :default => 1
  end

  def self.down
    change_column :works, :expected_number_of_chapters, :integer, :default => nil
  end
end
