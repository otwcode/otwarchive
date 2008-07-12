class CreateSellers < ActiveRecord::Migration
  def self.up
    create_table "sellers", :force => true do |t|
      t.integer  "user_id",                                                       :null => false
      t.string   "company_name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :sellers
  end
end
