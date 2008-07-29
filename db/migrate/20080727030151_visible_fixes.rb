class VisibleFixes < ActiveRecord::Migration
  def self.up
    change_column "works", "restricted", :boolean, :default => 0
    Work.find(:all, :conditions => 'restricted is NULL').each do |w|
       w.update_attribute(:restricted, 0)
    end
    change_column "bookmarks", "private", :boolean, :default => 0
    Bookmark.find(:all, :conditions => 'private is NULL').each do |b|
       b.update_attribute(:private, 0)
    end
  end

  def self.down
  end
end
