class AddChapterIndex < ActiveRecord::Migration
  def self.up
    add_index :chapters, [:work_id], :name => :works_chapter_index
  end

  def self.down
    remove_index :chapters, :name => :works_chapter_index
  end
end
