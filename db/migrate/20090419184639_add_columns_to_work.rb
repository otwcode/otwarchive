class AddColumnsToWork < ActiveRecord::Migration
  def self.up
    add_column :works, :authors_to_sort_on, :string
    add_column :works, :title_to_sort_on, :string
  end

  def self.down
    remove_column :works, :title_to_sort_on
    remove_column :works, :authors_to_sort_on
  end
end
