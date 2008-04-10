class RemoveTitleSummaryNotesFromWorks < ActiveRecord::Migration
  def self.up
    remove_column :works, :title
    remove_column :works, :summary
    remove_column :works, :notes
  end

  def self.down
    add_column :works, :notes, :text
    add_column :works, :summary, :text
    add_column :works, :title, :string
  end
end
