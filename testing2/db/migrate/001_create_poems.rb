class CreatePoems < ActiveRecord::Migration
  def self.up
    create_table :poems do |t|
      t.string :title
      t.string :author
      t.string :book

      t.timestamps
    end
  end

  def self.down
    drop_table :poems
  end
end
