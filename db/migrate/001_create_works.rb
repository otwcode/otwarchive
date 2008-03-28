class CreateWorks < ActiveRecord::Migration
  def self.up
    create_table :works do |t|
      t.string :title, :null => false
      t.text :summary
      t.text :notes
      t.datetime :date
      t.integer :expected_number_of_chapters
      t.boolean :is_complete

      t.timestamps
    end
  end

  def self.down
    drop_table :works
  end
end
