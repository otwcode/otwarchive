class CreateTagSets < ActiveRecord::Migration
  def self.up
    create_table :tag_sets do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_sets
  end
end
