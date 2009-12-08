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

ActiveRecord::Schema.define(:version => 20091208200602) do

  create_table "abuse_reports", :force => true do |t|
    t.string   "email"
    t.string   "url",        :default => "", :null => false
    t.text     "comment",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
    t.string   "category"
  end

  create_table "admin_posts", :force => true do |t|
    t.integer  "admin_id"
    t.string   "title"
    t.text     "content"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "admin_settings", :force => true do |t|
    t.boolean  "account_creation_enabled",                 :default => true,                  :null => false
    t.boolean  "invite_from_queue_enabled",                :default => true,                  :null => false
    t.integer  "invite_from_queue_number",    :limit => 8
    t.integer  "invite_from_queue_frequency", :limit => 3
    t.integer  "days_to_purge_unactivated",   :limit => 3
    t.integer  "last_updated_by",             :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "invite_from_queue_at",                     :default => '2009-11-02 20:22:37'
  end

  create_table "admins", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "login"
    t.string   "crypted_password"
    t.string   "salt"
  end

  create_table "archive_faqs", :force => true do |t|
    t.integer  "admin_id"
    t.string   "title"
    t.text     "content"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "bookmarks", :force => true do |t|
    t.datetime "created_at",                                         :null => false
    t.string   "bookmarkable_type", :limit => 15, :default => "",    :null => false
    t.integer  "bookmarkable_id",   :limit => 8,                     :null => false
    t.text     "notes"
    t.boolean  "private",                         :default => false
    t.datetime "updated_at"
    t.boolean  "hidden_by_admin",                 :default => false, :null => false
    t.integer  "pseud_id",                                           :null => false
    t.boolean  "rec",                             :default => false, :null => false
  end

  add_index "bookmarks", ["bookmarkable_id", "bookmarkable_type", "pseud_id"], :name => "index_bookmarkable_pseud"
  add_index "bookmarks", ["bookmarkable_id", "bookmarkable_type"], :name => "index_bookmarkable"
  add_index "bookmarks", ["pseud_id"], :name => "index_bookmarks_on_pseud_id"

  create_table "chapters", :force => true do |t|
    t.text     "content",         :limit => 2147483647,                    :null => false
    t.integer  "position",        :limit => 8,          :default => 1
    t.integer  "work_id",         :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "posted",                                :default => false, :null => false
    t.string   "title"
    t.text     "notes"
    t.text     "summary"
    t.integer  "word_count",      :limit => 8
    t.boolean  "hidden_by_admin",                       :default => false, :null => false
    t.date     "published_at"
    t.text     "endnotes"
  end

  add_index "chapters", ["work_id"], :name => "works_chapter_index"

  create_table "collection_items", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "item_id"
    t.string   "item_type",                               :default => "Work"
    t.integer  "user_approval_status",       :limit => 1, :default => 0,      :null => false
    t.integer  "collection_approval_status", :limit => 1, :default => 0,      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collection_items", ["collection_id", "item_id", "item_type"], :name => "by collection and item", :unique => true

  create_table "collection_participants", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "pseud_id"
    t.string   "participant_role", :default => "None", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collection_participants", ["collection_id", "pseud_id"], :name => "by collection and pseud", :unique => true

  create_table "collection_preferences", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "allowed_to_post", :limit => 1, :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collection_profiles", :force => true do |t|
    t.integer  "collection_id"
    t.text     "intro",         :limit => 16777215
    t.text     "faq",           :limit => 16777215
    t.text     "rules",         :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collections", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "email"
    t.string   "header_image_url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "pseud_id",         :limit => 8
    t.text     "content",                                          :null => false
    t.integer  "depth",            :limit => 8
    t.integer  "threaded_left",    :limit => 8
    t.integer  "threaded_right",   :limit => 8
    t.boolean  "is_deleted",                    :default => false, :null => false
    t.string   "name"
    t.string   "email"
    t.string   "ip_address"
    t.integer  "commentable_id",   :limit => 8
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "thread",           :limit => 8
    t.string   "user_agent"
    t.boolean  "approved",                      :default => false, :null => false
    t.boolean  "hidden_by_admin",               :default => false, :null => false
    t.datetime "edited_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_commentable"

  create_table "common_taggings", :force => true do |t|
    t.integer  "common_tag_id",   :limit => 8,   :null => false
    t.integer  "filterable_id",   :limit => 8,   :null => false
    t.string   "filterable_type", :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "common_taggings", ["common_tag_id", "filterable_type", "filterable_id"], :name => "index_common_tags", :unique => true

  create_table "creatorships", :force => true do |t|
    t.integer  "creation_id",   :limit => 8
    t.string   "creation_type", :limit => 100
    t.integer  "pseud_id",      :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "creatorships", ["creation_id", "creation_type", "pseud_id"], :name => "creation_id_creation_type_pseud_id", :unique => true
  add_index "creatorships", ["creation_id", "creation_type"], :name => "index_creatorships_creation"
  add_index "creatorships", ["pseud_id"], :name => "index_creatorships_pseud"

  create_table "external_author_names", :force => true do |t|
    t.integer  "external_author_id", :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_authors", :force => true do |t|
    t.string   "email"
    t.boolean  "is_claimed",    :default => false, :null => false
    t.integer  "user_id"
    t.boolean  "do_not_email",  :default => false, :null => false
    t.boolean  "do_not_import", :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_creatorships", :force => true do |t|
    t.integer  "creation_id"
    t.string   "creation_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "archivist_id"
    t.integer  "external_author_name_id"
  end

  create_table "external_works", :force => true do |t|
    t.string   "url",             :default => "",    :null => false
    t.string   "author",          :default => "",    :null => false
    t.boolean  "dead",            :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",           :default => "",    :null => false
    t.text     "summary"
    t.boolean  "hidden_by_admin", :default => false, :null => false
  end

  create_table "feedbacks", :force => true do |t|
    t.text     "comment",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "summary"
    t.string   "user_agent"
    t.string   "category"
  end

  create_table "filter_counts", :force => true do |t|
    t.integer  "filter_id",            :limit => 8,                :null => false
    t.integer  "public_works_count",   :limit => 8, :default => 0
    t.integer  "unhidden_works_count", :limit => 8, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "filter_taggings", :force => true do |t|
    t.integer  "filter_id",       :limit => 8,   :null => false
    t.integer  "filterable_id",   :limit => 8,   :null => false
    t.string   "filterable_type", :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "filter_taggings", ["filterable_id", "filterable_type"], :name => "index_filter_taggings_filterable"

  create_table "inbox_comments", :force => true do |t|
    t.integer  "user_id",             :limit => 8
    t.integer  "feedback_comment_id", :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "read",                             :default => false, :null => false
    t.boolean  "replied_to",                       :default => false, :null => false
  end

  create_table "invitations", :force => true do |t|
    t.integer  "creator_id",         :limit => 8
    t.string   "invitee_email"
    t.string   "token"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "used",                            :default => false, :null => false
    t.integer  "invitee_id"
    t.string   "invitee_type"
    t.string   "creator_type"
    t.datetime "redeemed_at"
    t.boolean  "from_queue",                      :default => false, :null => false
    t.integer  "external_author_id"
  end

  create_table "invite_requests", :force => true do |t|
    t.string   "email"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "known_issues", :force => true do |t|
    t.integer  "admin_id"
    t.string   "title"
    t.text     "content"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "languages", :force => true do |t|
    t.string "short", :limit => 4
    t.string "name"
  end

  create_table "locales", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.boolean  "main"
    t.datetime "updated_at"
    t.integer  "language_id", :null => false
  end

  add_index "locales", ["iso"], :name => "index_locales_on_iso"

  create_table "log_items", :force => true do |t|
    t.integer  "user_id",                 :null => false
    t.integer  "admin_id"
    t.integer  "role_id"
    t.integer  "action",     :limit => 1
    t.text     "note",                    :null => false
    t.datetime "enddate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "log_items", ["user_id"], :name => "index_log_items_on_user_id"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued",     :limit => 8
    t.integer "lifetime",   :limit => 8
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :limit => 8,                 :null => false
    t.string  "server_url"
    t.string  "salt",                    :default => "", :null => false
  end

  create_table "preferences", :force => true do |t|
    t.integer  "user_id",                  :limit => 8
    t.boolean  "history_enabled",                       :default => true
    t.boolean  "email_visible",                         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "date_of_birth_visible",                 :default => false
    t.boolean  "edit_emails_off",                       :default => false,                     :null => false
    t.boolean  "comment_emails_off",                    :default => false,                     :null => false
    t.boolean  "adult",                                 :default => false
    t.boolean  "hide_warnings",                         :default => false,                     :null => false
    t.boolean  "comment_inbox_off",                     :default => false
    t.boolean  "comment_copy_to_self_off",              :default => true,                      :null => false
    t.string   "work_title_format",                     :default => "TITLE - AUTHOR - FANDOM"
    t.boolean  "hide_freeform",                         :default => false,                     :null => false
    t.boolean  "first_login",                           :default => true
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id",       :limit => 8
    t.string   "location"
    t.text     "about_me"
    t.date     "date_of_birth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "pseuds", :force => true do |t|
    t.integer  "user_id",     :limit => 8
    t.string   "name",                     :default => "",    :null => false
    t.text     "description"
    t.boolean  "is_default",               :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pseuds", ["user_id", "name"], :name => "index_pseuds_on_user_id_and_name"

  create_table "readings", :force => true do |t|
    t.integer  "major_version_read", :limit => 8
    t.integer  "minor_version_read", :limit => 8
    t.integer  "user_id",            :limit => 8
    t.integer  "work_id",            :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "related_works", :force => true do |t|
    t.integer  "parent_id",   :limit => 8
    t.string   "parent_type"
    t.integer  "work_id",     :limit => 8
    t.boolean  "reciprocal",               :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id",   :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id",    :limit => 8
    t.integer  "role_id",    :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "serial_works", :force => true do |t|
    t.integer  "series_id",  :limit => 8
    t.integer  "work_id",    :limit => 8
    t.integer  "position",   :limit => 8, :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "series", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",           :default => "",    :null => false
    t.text     "summary"
    t.text     "notes"
    t.boolean  "hidden_by_admin", :default => false, :null => false
    t.boolean  "restricted",      :default => false, :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tagger_id",     :limit => 8
    t.integer  "taggable_id",   :limit => 8,                   :null => false
    t.string   "taggable_type", :limit => 100, :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tagger_type",   :limit => 100, :default => ""
  end

  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_taggable"
  add_index "taggings", ["tagger_id", "tagger_type", "taggable_id", "taggable_type"], :name => "index_taggings_polymorphic", :unique => true

  create_table "tags", :force => true do |t|
    t.string   "name",           :limit => 100, :default => ""
    t.boolean  "canonical",                     :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taggings_count", :limit => 8,   :default => 0
    t.boolean  "adult",                         :default => false
    t.string   "type"
    t.integer  "media_id",       :limit => 8
    t.integer  "fandom_id",      :limit => 8
    t.integer  "merger_id",      :limit => 8
    t.boolean  "has_characters",                :default => false, :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "translation_notes", :force => true do |t|
    t.text     "note"
    t.string   "namespace"
    t.integer  "user_id"
    t.integer  "locale_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translations", :force => true do |t|
    t.string   "tr_key"
    t.integer  "locale_id"
    t.text     "text"
    t.string   "namespace"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "updated",       :default => false, :null => false
    t.boolean  "betaed",        :default => false, :null => false
    t.integer  "translator_id"
    t.integer  "beta_id"
    t.boolean  "translated",    :default => false, :null => false
  end

  add_index "translations", ["tr_key", "locale_id", "updated_at"], :name => "index_translations_on_tr_key_and_locale_id_and_updated_at"
  add_index "translations", ["tr_key", "locale_id"], :name => "index_translations_on_tr_key_and_locale_id"

  create_table "user_invite_requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "quantity"
    t.text     "reason"
    t.boolean  "granted",    :default => false, :null => false
    t.boolean  "handled",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "identity_url",              :limit => 191
    t.boolean  "recently_reset",                           :default => false, :null => false
    t.boolean  "suspended",                                :default => false, :null => false
    t.boolean  "banned",                                   :default => false, :null => false
    t.integer  "invitation_id",             :limit => 8
    t.datetime "suspended_until"
    t.boolean  "out_of_invites",                           :default => true,  :null => false
  end

  add_index "users", ["identity_url"], :name => "index_users_on_identity_url", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login"

  create_table "works", :force => true do |t|
    t.integer  "expected_number_of_chapters", :limit => 8, :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "major_version",               :limit => 8, :default => 1
    t.integer  "minor_version",               :limit => 8, :default => 0
    t.boolean  "posted",                                   :default => false, :null => false
    t.integer  "language_id",                 :limit => 8
    t.boolean  "restricted",                               :default => false
    t.string   "title",                                    :default => "",    :null => false
    t.text     "summary"
    t.text     "notes"
    t.integer  "word_count",                  :limit => 8
    t.boolean  "hidden_by_admin",                          :default => false, :null => false
    t.boolean  "delta",                                    :default => false
    t.datetime "revised_at"
    t.string   "authors_to_sort_on"
    t.string   "title_to_sort_on"
    t.boolean  "backdate",                                 :default => false, :null => false
    t.text     "endnotes"
    t.string   "imported_from_url"
  end

end
