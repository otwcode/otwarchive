class CreateUserImports < ActiveRecord::Migration
  def self.up
    create_table :user_imports do |t|
      t.integer :user_id
      t.integer :pseud_id
      t.integer :source_archive_id
      t.integer :source_user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_imports
  end
end
