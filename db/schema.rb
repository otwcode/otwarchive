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

ActiveRecord::Schema.define(:version => 20100104232756) do

  create_table "abuse_reports", :force => true do |t|
    t.string   "email"
    t.string   "url",        :null => false
    t.text     "comment",    :null => false
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
    t.datetime "invite_from_queue_at",                     :default => '2009-11-07 21:27:21'
    t.boolean  "suspend_filter_counts",                    :default => false
    t.datetime "suspend_filter_counts_at"
    t.boolean  "enable_test_caching",                      :default => false
    t.integer  "cache_expiration",            :limit => 8, :default => 10
  end

  add_index "admin_settings", ["last_updated_by"], :name => "index_admin_settings_on_last_updated_by"

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
    t.integer  "position",   :default => 1
  end

  create_table "bookmarks", :force => true do |t|
    t.datetime "created_at",                                         :null => false
    t.string   "bookmarkable_type", :limit => 15,                    :null => false
    t.integer  "bookmarkable_id",                                    :null => false
    t.integer  "user_id"
    t.text     "notes"
    t.boolean  "private",                         :default => false
    t.datetime "updated_at"
    t.boolean  "hidden_by_admin",                 :default => false, :null => false
    t.integer  "pseud_id",                                           :null => false
    t.boolean  "rec",                             :default => false, :null => false
  end

  add_index "bookmarks", ["bookmarkable_id", "bookmarkable_type", "pseud_id"], :name => "index_bookmarkable_pseud"
  add_index "bookmarks", ["bookmarkable_id", "bookmarkable_type"], :name => "index_bookmarkable"
  add_index "bookmarks", ["private", "hidden_by_admin", "created_at"], :name => "index_bookmarks_on_private_and_hidden_by_admin_and_created_at"
  add_index "bookmarks", ["pseud_id"], :name => "index_bookmarks_on_pseud_id"
  add_index "bookmarks", ["user_id"], :name => "fk_bookmarks_user"

  create_table "chapters", :force => true do |t|
    t.text     "content",         :limit => 2147483647,                    :null => false
    t.integer  "position",                              :default => 1
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "posted",                                :default => false, :null => false
    t.string   "title"
    t.text     "notes"
    t.text     "summary"
    t.integer  "word_count"
    t.boolean  "hidden_by_admin",                       :default => false, :null => false
    t.date     "published_at"
    t.text     "endnotes"
  end

  add_index "chapters", ["work_id"], :name => "index_chapters_on_work_id"
  add_index "chapters", ["work_id"], :name => "works_chapter_index"

  create_table "collection_items", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "item_id"
    t.string   "item_type",                               :default => "Work"
    t.integer  "user_approval_status",       :limit => 1, :default => 0,      :null => false
    t.integer  "collection_approval_status", :limit => 1, :default => 0,      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "anonymous",                               :default => false,  :null => false
    t.boolean  "unrevealed",                              :default => false,  :null => false
  end

  add_index "collection_items", ["collection_id", "item_id", "item_type"], :name => "by collection and item", :unique => true
  add_index "collection_items", ["collection_id", "user_approval_status", "collection_approval_status"], :name => "index_collection_items_approval_status"

  create_table "collection_participants", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "pseud_id"
    t.string   "participant_role", :default => "None", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collection_participants", ["collection_id", "participant_role"], :name => "participants_by_collection_and_role"
  add_index "collection_participants", ["collection_id", "pseud_id"], :name => "by collection and pseud", :unique => true

  create_table "collection_preferences", :force => true do |t|
    t.integer  "collection_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "moderated",     :default => false, :null => false
    t.boolean  "closed",        :default => false, :null => false
    t.boolean  "unrevealed",    :default => false, :null => false
    t.boolean  "anonymous",     :default => false, :null => false
    t.boolean  "gift_exchange", :default => false, :null => false
  end

  add_index "collection_preferences", ["collection_id"], :name => "index_collection_preferences_on_collection_id"

  create_table "collection_profiles", :force => true do |t|
    t.integer  "collection_id"
    t.text     "intro",             :limit => 2147483647
    t.text     "faq",               :limit => 2147483647
    t.text     "rules",             :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "gift_notification"
  end

  add_index "collection_profiles", ["collection_id"], :name => "index_collection_profiles_on_collection_id"

  create_table "collections", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "email"
    t.string   "header_image_url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  add_index "collections", ["name"], :name => "index_collections_on_name"
  add_index "collections", ["parent_id"], :name => "index_collections_on_parent_id"

  create_table "comments", :force => true do |t|
    t.integer  "pseud_id"
    t.text     "content",                             :null => false
    t.integer  "depth"
    t.integer  "threaded_left"
    t.integer  "threaded_right"
    t.boolean  "is_deleted",       :default => false, :null => false
    t.string   "name"
    t.string   "email"
    t.string   "ip_address"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "thread"
    t.string   "user_agent"
    t.boolean  "approved",         :default => false, :null => false
    t.boolean  "hidden_by_admin",  :default => false, :null => false
    t.datetime "edited_at"
    t.integer  "parent_id"
    t.string   "parent_type"
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_commentable"
  add_index "comments", ["parent_id", "parent_type"], :name => "index_comments_parent"
  add_index "comments", ["pseud_id"], :name => "index_comments_on_pseud_id"

  create_table "common_taggings", :force => true do |t|
    t.integer  "common_tag_id",                  :null => false
    t.integer  "filterable_id",                  :null => false
    t.string   "filterable_type", :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "common_taggings", ["common_tag_id", "filterable_type", "filterable_id"], :name => "index_common_tags", :unique => true

  create_table "creatorships", :force => true do |t|
    t.integer  "creation_id"
    t.string   "creation_type", :limit => 100
    t.integer  "pseud_id"
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

  add_index "external_author_names", ["external_author_id"], :name => "index_external_author_names_on_external_author_id"

  create_table "external_authors", :force => true do |t|
    t.string   "email"
    t.boolean  "is_claimed",    :default => false, :null => false
    t.integer  "user_id"
    t.boolean  "do_not_email",  :default => false, :null => false
    t.boolean  "do_not_import", :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "external_authors", ["user_id"], :name => "index_external_authors_on_user_id"

  create_table "external_creatorships", :force => true do |t|
    t.integer  "creation_id"
    t.string   "creation_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "archivist_id"
    t.integer  "external_author_name_id"
  end

  add_index "external_creatorships", ["archivist_id"], :name => "index_external_creatorships_on_archivist_id"
  add_index "external_creatorships", ["creation_id", "creation_type"], :name => "index_external_creatorships_on_creation_id_and_creation_type"
  add_index "external_creatorships", ["external_author_name_id"], :name => "index_external_creatorships_on_external_author_name_id"

  create_table "external_works", :force => true do |t|
    t.string   "url",                                :null => false
    t.string   "author",                             :null => false
    t.boolean  "dead",            :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                              :null => false
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

  add_index "filter_counts", ["filter_id"], :name => "index_filter_counts_on_filter_id"

  create_table "filter_taggings", :force => true do |t|
    t.integer  "filter_id",       :limit => 8,   :null => false
    t.integer  "filterable_id",   :limit => 8,   :null => false
    t.string   "filterable_type", :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "filter_taggings", ["filter_id", "filterable_type"], :name => "index_filter_taggings_on_filter_id_and_filterable_type"
  add_index "filter_taggings", ["filterable_id", "filterable_type"], :name => "index_filter_taggings_filterable"

  create_table "gifts", :force => true do |t|
    t.integer  "work_id"
    t.string   "recipient_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gifts", ["recipient_name"], :name => "index_gifts_on_recipient_name"
  add_index "gifts", ["work_id"], :name => "index_gifts_on_work_id"

  create_table "inbox_comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "feedback_comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "read",                :default => false, :null => false
    t.boolean  "replied_to",          :default => false, :null => false
  end

  add_index "inbox_comments", ["feedback_comment_id"], :name => "index_inbox_comments_on_feedback_comment_id"
  add_index "inbox_comments", ["read", "user_id"], :name => "index_inbox_comments_on_read_and_user_id"

  create_table "invitations", :force => true do |t|
    t.integer  "creator_id"
    t.string   "invitee_email"
    t.string   "token"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "used",               :default => false, :null => false
    t.integer  "invitee_id"
    t.string   "invitee_type"
    t.string   "creator_type"
    t.datetime "redeemed_at"
    t.boolean  "from_queue",         :default => false, :null => false
    t.integer  "external_author_id"
  end

  add_index "invitations", ["creator_id", "creator_type"], :name => "index_invitations_on_creator_id_and_creator_type"
  add_index "invitations", ["external_author_id"], :name => "index_invitations_on_external_author_id"
  add_index "invitations", ["invitee_id", "invitee_type"], :name => "index_invitations_on_invitee_id_and_invitee_type"
  add_index "invitations", ["token"], :name => "index_invitations_on_token"

  create_table "invite_requests", :force => true do |t|
    t.string   "email"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invite_requests", ["email"], :name => "index_invite_requests_on_email"

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

  add_index "languages", ["short"], :name => "index_languages_on_short"

  create_table "locales", :force => true do |t|
    t.string   "iso"
    t.string   "short"
    t.string   "name"
    t.boolean  "main"
    t.datetime "updated_at"
    t.integer  "language_id", :null => false
  end

  add_index "locales", ["iso"], :name => "index_locales_on_iso"
  add_index "locales", ["language_id"], :name => "index_locales_on_language_id"
  add_index "locales", ["short"], :name => "index_locales_on_short"

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

  add_index "log_items", ["admin_id"], :name => "index_log_items_on_admin_id"
  add_index "log_items", ["role_id"], :name => "index_log_items_on_role_id"
  add_index "log_items", ["user_id"], :name => "index_log_items_on_user_id"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "preferences", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "history_enabled",                   :default => true
    t.boolean  "email_visible",                     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "date_of_birth_visible",             :default => false
    t.boolean  "edit_emails_off",                   :default => false,                     :null => false
    t.boolean  "comment_emails_off",                :default => false,                     :null => false
    t.boolean  "adult",                             :default => false
    t.boolean  "hide_warnings",                     :default => false,                     :null => false
    t.boolean  "comment_inbox_off",                 :default => false
    t.boolean  "comment_copy_to_self_off",          :default => true,                      :null => false
    t.string   "work_title_format",                 :default => "TITLE - AUTHOR - FANDOM"
    t.boolean  "hide_freeform",                     :default => false,                     :null => false
    t.boolean  "first_login",                       :default => true
    t.boolean  "automatically_approve_collections", :default => false,                     :null => false
    t.boolean  "collection_emails_off",             :default => false,                     :null => false
    t.boolean  "collection_inbox_off",              :default => false,                     :null => false
    t.boolean  "hide_private_hit_count",            :default => false,                     :null => false
    t.boolean  "hide_public_hit_count",             :default => false,                     :null => false
    t.boolean  "recipient_emails_off",              :default => false,                     :null => false
    t.boolean  "hide_all_hit_counts",               :default => false,                     :null => false
  end

  add_index "preferences", ["user_id"], :name => "index_preferences_on_user_id"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "location"
    t.text     "about_me"
    t.date     "date_of_birth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "pseuds", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",                           :null => false
    t.text     "description"
    t.boolean  "is_default",  :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pseuds", ["user_id", "name"], :name => "index_pseuds_on_user_id_and_name"

  create_table "readings", :force => true do |t|
    t.integer  "major_version_read"
    t.integer  "minor_version_read"
    t.integer  "user_id"
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "readings", ["user_id"], :name => "index_readings_on_user_id"
  add_index "readings", ["work_id"], :name => "index_readings_on_work_id"

  create_table "related_works", :force => true do |t|
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "work_id"
    t.boolean  "reciprocal",  :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "related_works", ["parent_id", "parent_type"], :name => "index_related_works_on_parent_id_and_parent_type"
  add_index "related_works", ["work_id"], :name => "index_related_works_on_work_id"

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["authorizable_id", "authorizable_type"], :name => "index_roles_on_authorizable_id_and_authorizable_type"
  add_index "roles", ["authorizable_type"], :name => "index_roles_on_authorizable_type"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id"
  add_index "roles_users", ["user_id", "role_id"], :name => "index_roles_users_on_user_id_and_role_id"

  create_table "serial_works", :force => true do |t|
    t.integer  "series_id"
    t.integer  "work_id"
    t.integer  "position",   :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "serial_works", ["series_id"], :name => "index_serial_works_on_series_id"
  add_index "serial_works", ["work_id"], :name => "index_serial_works_on_work_id"

  create_table "series", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                              :null => false
    t.text     "summary"
    t.text     "notes"
    t.boolean  "hidden_by_admin", :default => false, :null => false
    t.boolean  "restricted",      :default => true,  :null => false
  end

  create_table "set_taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "tag_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tag_sets", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tagger_id"
    t.integer  "taggable_id",                                  :null => false
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
    t.integer  "taggings_count",                :default => 0
    t.boolean  "adult",                         :default => false
    t.string   "type"
    t.integer  "media_id"
    t.integer  "fandom_id"
    t.integer  "merger_id"
    t.boolean  "wrangled",                      :default => false, :null => false
    t.boolean  "has_characters",                :default => false, :null => false
  end

  add_index "tags", ["fandom_id"], :name => "index_tags_on_fandom_id"
  add_index "tags", ["id", "type"], :name => "index_tags_on_id_and_type"
  add_index "tags", ["media_id", "type"], :name => "index_tags_on_media_id_and_type"
  add_index "tags", ["merger_id"], :name => "index_tags_on_merger_id"
  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "translation_notes", :force => true do |t|
    t.text     "note"
    t.string   "namespace"
    t.integer  "user_id"
    t.integer  "locale_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "translation_notes", ["locale_id"], :name => "index_translation_notes_on_locale_id"
  add_index "translation_notes", ["user_id"], :name => "index_translation_notes_on_user_id"

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

  add_index "user_invite_requests", ["user_id"], :name => "index_user_invite_requests_on_user_id"

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
    t.integer  "invitation_id"
    t.datetime "suspended_until"
    t.boolean  "out_of_invites",                           :default => true,  :null => false
  end

  add_index "users", ["activation_code"], :name => "index_users_on_activation_code"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["identity_url"], :name => "index_users_on_identity_url", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login"

  create_table "works", :force => true do |t|
    t.integer  "expected_number_of_chapters", :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "major_version",               :default => 1
    t.integer  "minor_version",               :default => 0
    t.boolean  "posted",                      :default => false, :null => false
    t.integer  "language_id"
    t.boolean  "restricted",                  :default => false
    t.string   "title",                                          :null => false
    t.text     "summary"
    t.text     "notes"
    t.integer  "word_count"
    t.boolean  "hidden_by_admin",             :default => false, :null => false
    t.boolean  "delta",                       :default => false
    t.datetime "revised_at"
    t.string   "authors_to_sort_on"
    t.string   "title_to_sort_on"
    t.boolean  "backdate",                    :default => false, :null => false
    t.text     "endnotes"
    t.string   "imported_from_url"
    t.integer  "hit_count",                   :default => 0,     :null => false
    t.string   "last_visitor"
  end

  add_index "works", ["imported_from_url"], :name => "index_works_on_imported_from_url"
  add_index "works", ["language_id"], :name => "index_works_on_language_id"

end
