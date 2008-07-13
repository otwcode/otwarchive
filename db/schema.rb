# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080713141605) do

  create_table "abuse_reports", :force => true do |t|
    t.string   "email"
    t.string   "url"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admins", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "login"
    t.string   "crypted_password"
    t.string   "salt"
  end

  create_table "bookmarks", :force => true do |t|
    t.datetime "created_at",                                      :null => false
    t.string   "bookmarkable_type", :limit => 15, :default => "", :null => false
    t.integer  "bookmarkable_id",   :limit => 11, :default => 0,  :null => false
    t.integer  "user_id",           :limit => 11, :default => 0,  :null => false
    t.text     "notes"
    t.boolean  "private"
    t.datetime "updated_at"
  end

  add_index "bookmarks", ["user_id"], :name => "fk_bookmarks_user"

  create_table "chapters", :force => true do |t|
    t.text     "content"
    t.integer  "position",   :limit => 11, :default => 1
    t.integer  "work_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "posted"
  end

  create_table "comments", :force => true do |t|
    t.integer  "pseud_id",         :limit => 11
    t.text     "content"
    t.integer  "depth",            :limit => 11
    t.integer  "threaded_left",    :limit => 11
    t.integer  "threaded_right",   :limit => 11
    t.boolean  "is_deleted"
    t.string   "name"
    t.string   "email"
    t.string   "ip_address"
    t.integer  "commentable_id",   :limit => 11
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "thread",           :limit => 11
    t.string   "user_agent"
    t.boolean  "approved"
  end

  create_table "communities", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "open_membership"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "creatorships", :force => true do |t|
    t.integer  "creation_id",   :limit => 11
    t.string   "creation_type"
    t.integer  "pseud_id",      :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_works", :force => true do |t|
    t.string   "url"
    t.string   "author"
    t.boolean  "dead"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", :force => true do |t|
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "globalize_countries", :force => true do |t|
    t.string "code",                   :limit => 2
    t.string "english_name"
    t.string "date_format"
    t.string "currency_format"
    t.string "currency_code",          :limit => 3
    t.string "thousands_sep",          :limit => 2
    t.string "decimal_sep",            :limit => 2
    t.string "currency_decimal_sep",   :limit => 2
    t.string "number_grouping_scheme"
  end

  add_index "globalize_countries", ["code"], :name => "index_globalize_countries_on_code"

  create_table "globalize_languages", :force => true do |t|
    t.string  "iso_639_1",             :limit => 2
    t.string  "iso_639_2",             :limit => 3
    t.string  "iso_639_3",             :limit => 3
    t.string  "rfc_3066"
    t.string  "english_name"
    t.string  "english_name_locale"
    t.string  "english_name_modifier"
    t.string  "native_name"
    t.string  "native_name_locale"
    t.string  "native_name_modifier"
    t.boolean "macro_language"
    t.string  "direction"
    t.string  "pluralization"
    t.string  "scope",                 :limit => 1
  end

  add_index "globalize_languages", ["iso_639_1"], :name => "index_globalize_languages_on_iso_639_1"
  add_index "globalize_languages", ["iso_639_2"], :name => "index_globalize_languages_on_iso_639_2"
  add_index "globalize_languages", ["iso_639_3"], :name => "index_globalize_languages_on_iso_639_3"
  add_index "globalize_languages", ["rfc_3066"], :name => "index_globalize_languages_on_rfc_3066"

  create_table "globalize_translations", :force => true do |t|
    t.string  "type"
    t.string  "tr_key"
    t.string  "table_name"
    t.integer "item_id",             :limit => 11
    t.string  "facet"
    t.boolean "built_in"
    t.integer "language_id",         :limit => 11
    t.integer "pluralization_index", :limit => 11
    t.text    "text"
    t.string  "namespace"
  end

  add_index "globalize_translations", ["tr_key", "language_id"], :name => "index_globalize_translations_on_tr_key_and_language_id"
  add_index "globalize_translations", ["table_name", "item_id", "language_id"], :name => "globalize_translations_table_name_and_item_and_language"

  create_table "inbox_comments", :force => true do |t|
    t.integer  "user_id",             :limit => 11
    t.integer  "feedback_comment_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "metadatas", :force => true do |t|
    t.string   "title"
    t.text     "summary"
    t.text     "notes"
    t.integer  "described_id",   :limit => 11
    t.string   "described_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued",     :limit => 11
    t.integer "lifetime",   :limit => 11
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :limit => 11,                 :null => false
    t.string  "server_url"
    t.string  "salt",                     :default => "", :null => false
  end

  create_table "preferences", :force => true do |t|
    t.integer  "user_id",               :limit => 11
    t.boolean  "history_enabled",                     :default => true
    t.boolean  "email_visible",                       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "date_of_birth_visible",               :default => false
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id",       :limit => 11
    t.string   "location"
    t.text     "about_me"
    t.date     "date_of_birth"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pseuds", :force => true do |t|
    t.integer  "user_id",     :limit => 11
    t.string   "name"
    t.text     "description"
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "readings", :force => true do |t|
    t.integer  "major_version_read", :limit => 11
    t.integer  "minor_version_read", :limit => 11
    t.integer  "user_id",            :limit => 11
    t.integer  "work_id",            :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "related_works", :force => true do |t|
    t.integer  "parent_id",   :limit => 11
    t.integer  "work_id",     :limit => 11
    t.boolean  "reciprocal"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parent_type"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id",    :limit => 11
    t.integer  "role_id",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "serial_works", :force => true do |t|
    t.integer  "series_id",  :limit => 11
    t.integer  "work_id",    :limit => 11
    t.integer  "position",   :limit => 11, :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tag_categories", :force => true do |t|
    t.string   "name",         :default => "", :null => false
    t.boolean  "required"
    t.boolean  "official"
    t.boolean  "exclusive"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
  end

  add_index "tag_categories", ["name"], :name => "index_tag_categories_on_name", :unique => true

  create_table "tag_relationships", :force => true do |t|
    t.string   "name",                      :default => "", :null => false
    t.string   "verb_phrase",               :default => "", :null => false
    t.boolean  "reciprocal"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "distance",    :limit => 11,                 :null => false
  end

  add_index "tag_relationships", ["name"], :name => "index_tag_relationships_on_name", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id",              :limit => 11
    t.integer  "tag_relationship_id", :limit => 11
    t.integer  "taggable_id",         :limit => 11
    t.string   "taggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true

  create_table "tags", :force => true do |t|
    t.string   "name",                          :default => "", :null => false
    t.boolean  "canonical"
    t.boolean  "banned"
    t.integer  "tag_category_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taggings_count",  :limit => 11, :default => 0
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.string   "email"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code"
    t.string   "login"
    t.datetime "activated_at"
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "identity_url"
    t.boolean  "recently_reset"
  end

  create_table "works", :force => true do |t|
    t.integer  "expected_number_of_chapters", :limit => 11, :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "major_version",               :limit => 11, :default => 0
    t.integer  "minor_version",               :limit => 11, :default => 0
    t.boolean  "posted"
    t.integer  "language_id",                 :limit => 11
    t.boolean  "restricted"
  end

end
