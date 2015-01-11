class AddAkismetScoreToWorks < ActiveRecord::Migration
  def self.up
    add_column :works, :akismet_score, :boolean
    add_index "works", "akismet_score"
  end

  def self.down
    remove_index "works", "akismet_score"
    remove_column :works, :akismet_score
  end
end
