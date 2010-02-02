class AddWranglingAssignments < ActiveRecord::Migration
  def self.up
    create_table :wrangling_assignments, :force => true do |t|
      t.integer :user_id, :null => :false
      t.integer :fandom_id, :null => :false      
    end
  end

  def self.down
    drop_table :wrangling_assignments
  end
end
