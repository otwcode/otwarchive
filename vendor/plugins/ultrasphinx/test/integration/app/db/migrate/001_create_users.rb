class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.string   "login",                       :limit => 64, :default => "",        :null => false
      t.string   "email",                                     :default => "",        :null => false
      t.string   "crypted_password",            :limit => 64, :default => "",        :null => false
      t.string   "salt",                        :limit => 64, :default => "",        :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :users
  end
end
