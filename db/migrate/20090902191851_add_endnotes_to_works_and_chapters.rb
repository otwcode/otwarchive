class AddEndnotesToWorksAndChapters < ActiveRecord::Migration
  def self.up
    add_column :works, :endnotes, :text
    add_column :chapters, :endnotes, :text
  end

  def self.down
    remove_column :works, :endnotes
    remove_column :chapters, :endnotes
  end
end
