class CreateRelatedWorks < ActiveRecord::Migration
  def self.up
    create_table :related_works do |t|
      t.integer :parent_id
      t.string :parent_type
      t.references :work
      t.boolean :reciprocal

      t.timestamps
    end
  end

  def self.down
    drop_table :related_works
  end
end
