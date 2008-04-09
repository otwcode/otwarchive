ActiveRecord::Schema.define(:version => 0) do
  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end
end
