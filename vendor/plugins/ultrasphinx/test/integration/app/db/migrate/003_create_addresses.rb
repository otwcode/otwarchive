class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table "addresses", :force => true do |t|
      t.integer "user_id",                               :null => false
      t.string  "name"
      t.string  "line_1",                :default => "", :null => false
      t.string  "line_2"
      t.string  "city",                  :default => "", :null => false
      t.integer "state_id",                              :null => false
      t.string  "province_region"
      t.string  "zip_postal_code"
      t.integer "country_id",                            :null => false
    end
  end

  def self.down
    drop_table :addresses
  end
end
