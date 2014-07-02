class AddChapterWorkPositionIndex < ActiveRecord::Migration
  def self.up
    # remove duplicate indexes
    remove_index(:chapters, :name => 'index_chapters_on_work_id')
    #remove_index(:chapters, :name => 'works_chapter_index')
    # add index for work_id & position
    #add_index(:chapters, [:work_id,:position], :unique => true, :name => 'work_id_position')

  end

  def self.down
  # re-add duplicate index
   add_index(:chapters, :work_id, :name => 'index_chapters_on_work_id')
   #add_index(:chapters, :work_id, :name => 'works_chapter_index')
  #remove index on work_id / work_id
   #remove_index(:chapters, :name => 'work_id_position')
  end
end

