class RemoveCommunities < ActiveRecord::Migration
  def self.up
    drop_table :communities
  end

  def self.down
    create_table "communities", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.boolean  "open_membership"
    end
    
  end
end
