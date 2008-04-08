class CreateChapters < ActiveRecord::Migration
  def self.up
    create_table :chapters do |t|
      t.string :title
      t.text :content, :limit => 16777215
      t.integer :order, :default => 1
      t.references :work

      t.timestamps
    end
  end

  def self.down
    drop_table :chapters
  end
end
