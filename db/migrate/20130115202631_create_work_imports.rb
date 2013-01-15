class CreateWorkImports < ActiveRecord::Migration
  def self.up
    create_table :work_imports do |t|
      t.integer :work_id
      t.integer :pseud_id
      t.integer :source_archive_id
      t.integer :source_work_id
      t.integer :source_user_id

      t.timestamps

    end
  end

  def self.down
    drop_table :work_imports
  end
end
