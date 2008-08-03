class AddWordCount < ActiveRecord::Migration
  def self.up
    add_column :chapters, :word_count, :integer
    add_column :works, :word_count, :integer
    
    Chapter.all.each {|c| c.update_attribute(:word_count, c.content.split.length)}
    Work.all.each {|w| w.update_attribute(:word_count, w.chapters.collect(&:word_count).compact.sum)}
  end

  def self.down
    remove_column :works, :word_count
    remove_column :chapters, :word_count
  end
end 
