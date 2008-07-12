class CreateStates < ActiveRecord::Migration
  def self.up
    create_table "states", :force => true do |t|
      t.string "name",         :default => "", :null => false
      t.string "abbreviation", :default => "", :null => false
    end
  end

  def self.down
    drop_table "states"
  end
end
