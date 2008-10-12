class AddPublishedAtAndRevisedAtToWorks < ActiveRecord::Migration
  def self.up
    add_column :works, :published_at, :datetime
    add_column :works, :revised_at, :datetime
    Work.reset_column_information
    Work.find(:all).each do |work|
      chapter_date = work.chapters.find(:last).created_at
      work.published_at = work.created_at
      work.revised_at = chapter_date
      work.save
    end
  end

  def self.down
    remove_column :works, :revised_at
    remove_column :works, :published_at
  end
end
