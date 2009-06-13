class AddFilterCounts < ActiveRecord::Migration
  def self.up
    create_table :filter_counts do |t|
      t.integer  :filter_id,              :limit => 8,  :null => false
      t.integer  :public_works_count,     :limit => 8,  :default => 0
      t.integer  :unhidden_works_count,   :limit => 8,  :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :filter_counts
  end

end
