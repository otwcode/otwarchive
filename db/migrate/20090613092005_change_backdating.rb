class ChangeBackdating < ActiveRecord::Migration
  def self.up
    add_column :chapters, :published_at, :date
    add_column :works, :backdate, :boolean, :default => false, :null => false   
  end

  def self.down
    remove_column :chapters, :published_at
    remove_column :works, :backdate
  end
end