# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121129192353) do

  create_table "abuse_reports", :force => true do |t|
    t.string   "email"
    t.string   "url",                                                   :null => false
    t.text     "comment",                                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
    t.string   "category"
    t.integer  "comment_sanitizer_version", :limit => 2, :default => 0, :null => false
  end

  create_table "admin_post_taggings", :force => true do |t|
    t.integer  "admin_post_tag_id"
    t.integer  "admin_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_post_taggings", ["admin_post_id"], :name => "index_admin_post_taggings_on_admin_post_id"

  create_table "admin_post_tags", :force => true do |t|
    t.string   "name"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_posts", :force => true do |t|
    t.integer  "admin_id"
    t.string   "title"
    t.text     "content"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "content_sanitizer_version", :limit => 2, :default => 0, :null => false
    t.integer  "translated_post_id"
    t.integer  "language_id"
  end

  add_index "admin_posts", ["created_at"], :name => "index_admin_posts_on_created_at"
  add_index "admin_posts", ["translated_post_id"], :name => "index_admin_posts_on_post_id"

  create_table "admin_settings", :force => true do |t|
    t.boolean  "account_creation_enabled",                   :default => true,                  :null => false
    t.boolean  "invite_from_queue_enabled",                  :default => true,                  :null => false
    t.integer  "invite_from_queue_number",      :limit => 8
    t.integer  "invite_from_queue_frequency",   :limit => 3
    t.integer  "days_to_purge_unactivated",     :limit => 3
    t.integer  "last_updated_by",               :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "invite_from_queue_at",                       :default => '2009-11-07 21:27:21'
    t.boolean  "suspend_filter_counts",                      :default => false
    t.datetime "suspend_filter_counts_at"
    t.boolean  "enable_test_caching",                        :default => false
    t.integer  "cache_expiration",              :limit => 8, :default => 10
    t.boolean  "tag_wrangling_off",                          :default => false,                 :null => false
    t.boolean  "guest_downloading_off",                      :default => false,                 :null => false
    t.text     "banner_text"
    t.integer  "banner_text_sanitizer_version", :limit => 2, :default => 0,                     :null => false
    t.integer  "default_skin_id"
    t.datetime "stats_updated_at"
    t.boolean  "disable_filtering",                          :default => false,                 :null => false
    t.boolean  "request_invite_enabled",                     :default => false,                 :null => false
  end

  add_index "admin_settings", ["last_updated_by"], :name => "index_admin_settings_on_last_updated_by"

  create_table "admins", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "login"
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "persistence_token", :null => false
  end

  create_table "archive_faqs", :force => true do |t|
    t.integer  "admin_id"
    t.string   "title"
    t.text     "content"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "position",                               :default => 1
    t.integer  "content_sanitizer_version", :limit => 2, :default => 0, :null => false
  end

  create_table "bookmarks", :force => true do |t|
    t.datetime "created_at",                                               :null => false
    t.string   "bookmarkable_type",       :limit => 15,                    :null => false
    t.integer  "bookmarkable_id",                                          :null => false
    t.integer  "user_id"
    t.text     "notes"
    t.boolean  "private",                               :default => false
    t.datetime "updated_at"
    t.boolean  "hidden_by_admin",                       :default => false, :null => false
    t.integer  "pseud_id",                                                 :null => false
    t.boolean  "rec",                                   :default => false, :null => false
    t.boolean  "delta",                                 :default => true
    t.integer  "notes_sanitizer_version", :limit => 2,  :default => 0,     :null => false
  end

  add_index "bookmarks", ["bookmarkable_id", "bookmarkable_type", "pseud_id"], :name => "index_bookmarkable_pseud"
  add_index "bookmarks", ["bookmarkable_id", "bookmarkable_type"], :name => "index_bookmarkable"
  add_index "bookmarks", ["private", "hidden_by_admin", "created_at"], :name => "index_bookmarks_on_private_and_hidden_by_admin_and_created_at"
  add_index "bookmarks", ["pseud_id"], :name => "index_bookmarks_on_pseud_id"
  add_index "bookmarks", ["user_id"], :name => "fk_bookmarks_user"

  create_table "challenge_assignments", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "creation_id"
    t.string   "creation_type"
    t.integer  "offer_signup_id"
    t.integer  "request_signup_id"
    t.integer  "pinch_hitter_id"
    t.datetime "sent_at"
    t.datetime "fulfilled_at"
    t.datetime "defaulted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pinch_request_signup_id"
    t.datetime "covered_at"
  end

  add_index "challenge_assignments", ["collection_id"], :name => "index_challenge_assignments_on_collection_id"
  add_index "challenge_assignments", ["creation_id"], :name => "assignments_on_creation_id"
  add_index "challenge_assignments", ["creation_type"], :name => "assignments_on_creation_type"
  add_index "challenge_assignments", ["defaulted_at"], :name => "assignments_on_defaulted_at"
  add_index "challenge_assignments", ["offer_signup_id"], :name => "assignments_on_offer_signup_id"
  add_index "challenge_assignments", ["pinch_hitter_id"], :name => "assignments_on_pinch_hitter_id"
  add_index "challenge_assignments", ["sent_at"], :name => "assignments_on_offer_sent_at"

  create_table "challenge_claims", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "creation_id"
    t.string   "creation_type"
    t.integer  "request_signup_id"
    t.integer  "request_prompt_id"
    t.integer  "claiming_user_id"
    t.datetime "sent_at"
    t.datetime "fulfilled_at"
    t.datetime "defaulted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "challenge_claims", ["claiming_user_id"], :name => "index_challenge_claims_on_claiming_user_id"
  add_index "challenge_claims", ["collection_id"], :name => "index_challenge_claims_on_collection_id"
  add_index "challenge_claims", ["creation_id", "creation_type"], :name => "creations"
  add_index "challenge_claims", ["creation_id"], :name => "index_challenge_claims_on_creation_id"
  add_index "challenge_claims", ["request_signup_id"], :name => "index_challenge_claims_on_request_signup_id"

  create_table "challenge_signups", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "pseud_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "assigned_as_request", :default => false
    t.boolean  "assigned_as_offer",   :default => false
  end

  add_index "challenge_signups", ["collection_id"], :name => "index_challenge_signups_on_collection_id"
  add_index "challenge_signups", ["pseud_id"], :name => "signups_on_pseud_id"

  create_table "chapters", :force => true do |t|
    t.text     "content",                    :limit => 2147483647,                    :null => false
    t.integer  "position",                                         :default => 1
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "posted",                                           :default => false, :null => false
    t.string   "title"
    t.text     "notes"
    t.text     "summary"
    t.integer  "word_count"
    t.boolean  "hidden_by_admin",                                  :default => false, :null => false
    t.date     "published_at"
    t.text     "endnotes"
    t.integer  "content_sanitizer_version",  :limit => 2,          :default => 0,     :null => false
    t.integer  "notes_sanitizer_version",    :limit => 2,          :default => 0,     :null => false
    t.integer  "summary_sanitizer_version",  :limit => 2,          :default => 0,     :null => false
    t.integer  "endnotes_sanitizer_version", :limit => 2,          :default => 0,     :null => false
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

  add_index "collection_items", ["anonymous"], :name => "collection_items_anonymous"
  add_index "collection_items", ["collection_id", "item_id", "item_type"], :name => "by collection and item", :unique => true
  add_index "collection_items", ["collection_id", "user_approval_status", "collection_approval_status"], :name => "index_collection_items_approval_status"
  add_index "collection_items", ["item_id"], :name => "collection_items_item_id"
  add_index "collection_items", ["unrevealed"], :name => "collection_items_unrevealed"

  create_table "collection_participants", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "pseud_id"
    t.string   "participant_role", :default => "None", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collection_participants", ["collection_id", "participant_role"], :name => "participants_by_collection_and_role"
  add_index "collection_participants", ["collection_id", "pseud_id"], :name => "by collection and pseud", :unique => true
  add_index "collection_participants", ["pseud_id"], :name => "participants_pseud_id"

  create_table "collection_preferences", :force => true do |t|
    t.integer  "collection_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "moderated",     :default => false, :null => false
    t.boolean  "closed",        :default => false, :null => false
    t.boolean  "unrevealed",    :default => false, :null => false
    t.boolean  "anonymous",     :default => false, :null => false
    t.boolean  "gift_exchange", :default => false, :null => false
    t.boolean  "show_random",   :default => false, :null => false
    t.boolean  "prompt_meme",   :default => false, :null => false
    t.boolean  "email_notify",  :default => false, :null => false
  end

  add_index "collection_preferences", ["collection_id"], :name => "index_collection_preferences_on_collection_id"

  create_table "collection_profiles", :force => true do |t|
    t.integer  "collection_id"
    t.text     "intro",                   :limit => 2147483647
    t.text     "faq",                     :limit => 2147483647
    t.text     "rules",                   :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "gift_notification"
    t.integer  "intro_sanitizer_version", :limit => 2,          :default => 0, :null => false
    t.integer  "faq_sanitizer_version",   :limit => 2,          :default => 0, :null => false
    t.integer  "rules_sanitizer_version", :limit => 2,          :default => 0, :null => false
    t.text     "assignment_notification"
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
    t.integer  "challenge_id"
    t.string   "challenge_type"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.integer  "description_sanitizer_version", :limit => 2, :default => 0,  :null => false
    t.string   "icon_alt_text",                              :default => ""
    t.string   "icon_comment_text",                          :default => ""
  end

  add_index "collections", ["name"], :name => "index_collections_on_name"
  add_index "collections", ["parent_id"], :name => "index_collections_on_parent_id"

  create_table "comments", :force => true do |t|
    t.integer  "pseud_id"
    t.text     "content",                                                   :null => false
    t.integer  "depth"
    t.integer  "threaded_left"
    t.integer  "threaded_right"
    t.boolean  "is_deleted",                             :default => false, :null => false
    t.string   "name"
    t.string   "email"
    t.string   "ip_address"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "thread"
    t.string   "user_agent"
    t.boolean  "approved",                               :default => false, :null => false
    t.boolean  "hidden_by_admin",                        :default => false, :null => false
    t.datetime "edited_at"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "content_sanitizer_version", :limit => 2, :default => 0,     :null => false
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_commentable"
  add_index "comments", ["parent_id", "parent_type"], :name => "index_comments_parent"
  add_index "comments", ["pseud_id"], :name => "index_comments_on_pseud_id"
  add_index "comments", ["thread"], :name => "comments_by_thread"

  create_table "common_taggings", :force => true do |t|
    t.integer  "common_tag_id",                  :null => false
    t.integer  "filterable_id",                  :null => false
    t.string   "filterable_type", :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "common_taggings", ["common_tag_id", "filterable_type", "filterable_id"], :name => "index_common_tags", :unique => true
  add_index "common_taggings", ["filterable_id"], :name => "index_common_taggings_on_filterable_id"

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

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["failed_at"], :name => "delayed_jobs_failed_at"
  add_index "delayed_jobs", ["locked_at"], :name => "delayed_jobs_locked_at"
  add_index "delayed_jobs", ["locked_by"], :name => "delayed_jobs_locked_by"
  add_index "delayed_jobs", ["run_at"], :name => "delayed_jobs_run_at"

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

  add_index "external_authors", ["email"], :name => "index_external_authors_on_email"
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
    t.string   "url",                                                       :null => false
    t.string   "author",                                                    :null => false
    t.boolean  "dead",                                   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                                                     :null => false
    t.text     "summary"
    t.boolean  "hidden_by_admin",                        :default => false, :null => false
    t.integer  "summary_sanitizer_version", :limit => 2, :default => 0,     :null => false
    t.integer  "language_id"
  end

  create_table "feedbacks", :force => true do |t|
    t.text     "comment",                                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "summary"
    t.string   "user_agent"
    t.string   "category"
    t.integer  "comment_sanitizer_version", :limit => 2, :default => 0,     :null => false
    t.integer  "summary_sanitizer_version", :limit => 2, :default => 0,     :null => false
    t.boolean  "approved",                               :default => false, :null => false
    t.string   "ip_address"
  end

  create_table "filter_counts", :force => true do |t|
    t.integer  "filter_id",            :limit => 8,                :null => false
    t.integer  "public_works_count",   :limit => 8, :default => 0
    t.integer  "unhidden_works_count", :limit => 8, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "filter_counts", ["filter_id"], :name => "index_filter_counts_on_filter_id", :unique => true
  add_index "filter_counts", ["public_works_count"], :name => "index_public_works_count"
  add_index "filter_counts", ["unhidden_works_count"], :name => "index_unhidden_works_count"

  create_table "filter_taggings", :id => false, :force => true do |t|
    t.integer  "id",                                                :null => false
    t.integer  "filter_id",       :limit => 8,                      :null => false
    t.integer  "filterable_id",   :limit => 8,                      :null => false
    t.string   "filterable_type", :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "inherited",                      :default => false, :null => false
  end

  add_index "filter_taggings", ["filter_id", "filterable_type"], :name => "index_filter_taggings_on_filter_id_and_filterable_type"
  add_index "filter_taggings", ["filterable_id", "filterable_type"], :name => "index_filter_taggings_filterable"

  create_table "gift_exchanges", :force => true do |t|
    t.integer  "request_restriction_id"
    t.integer  "offer_restriction_id"
    t.integer  "requests_num_required",                                       :default => 1,     :null => false
    t.integer  "offers_num_required",                                         :default => 1,     :null => false
    t.integer  "requests_num_allowed",                                        :default => 1,     :null => false
    t.integer  "offers_num_allowed",                                          :default => 1,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "signup_instructions_general"
    t.text     "signup_instructions_requests"
    t.text     "signup_instructions_offers"
    t.boolean  "signup_open",                                                 :default => false, :null => false
    t.datetime "signups_open_at"
    t.datetime "signups_close_at"
    t.datetime "assignments_due_at"
    t.datetime "works_reveal_at"
    t.datetime "authors_reveal_at"
    t.integer  "prompt_restriction_id"
    t.string   "request_url_label"
    t.string   "request_description_label"
    t.string   "offer_url_label"
    t.string   "offer_description_label"
    t.string   "time_zone"
    t.integer  "potential_match_settings_id"
    t.datetime "assignments_sent_at"
    t.integer  "signup_instructions_general_sanitizer_version",  :limit => 2, :default => 0,     :null => false
    t.integer  "signup_instructions_requests_sanitizer_version", :limit => 2, :default => 0,     :null => false
    t.integer  "signup_instructions_offers_sanitizer_version",   :limit => 2, :default => 0,     :null => false
    t.boolean  "requests_summary_visible",                                    :default => false, :null => false
  end

  create_table "gifts", :force => true do |t|
    t.integer  "work_id"
    t.string   "recipient_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pseud_id"
  end

  add_index "gifts", ["pseud_id"], :name => "index_gifts_on_pseud_id"
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
  add_index "inbox_comments", ["user_id"], :name => "index_inbox_comments_on_user_id"

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
    t.integer  "content_sanitizer_version", :limit => 2, :default => 0, :null => false
  end

  create_table "kudos", :force => true do |t|
    t.integer  "pseud_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
  end

  add_index "kudos", ["commentable_id", "commentable_type", "pseud_id"], :name => "index_kudos_on_commentable_id_and_commentable_type_and_pseud_id"
  add_index "kudos", ["commentable_id", "commentable_type"], :name => "index_kudos_on_commentable_id_and_commentable_type"
  add_index "kudos", ["ip_address"], :name => "index_kudos_on_ip_address"
  add_index "kudos", ["pseud_id"], :name => "index_kudos_on_pseud_id"

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
    t.integer  "user_id",                                            :null => false
    t.integer  "admin_id"
    t.integer  "role_id"
    t.integer  "action",                 :limit => 1
    t.text     "note",                                               :null => false
    t.datetime "enddate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "note_sanitizer_version", :limit => 2, :default => 0, :null => false
  end

  add_index "log_items", ["admin_id"], :name => "index_log_items_on_admin_id"
  add_index "log_items", ["role_id"], :name => "index_log_items_on_role_id"
  add_index "log_items", ["user_id"], :name => "index_log_items_on_user_id"

  create_table "meta_taggings", :force => true do |t|
    t.integer  "meta_tag_id", :limit => 8,                   :null => false
    t.integer  "sub_tag_id",  :limit => 8,                   :null => false
    t.boolean  "direct",                   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meta_taggings", ["meta_tag_id"], :name => "index_meta_taggings_on_meta_tag_id"
  add_index "meta_taggings", ["sub_tag_id"], :name => "index_meta_taggings_on_sub_tag_id"

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

  create_table "owned_set_taggings", :force => true do |t|
    t.integer  "owned_tag_set_id"
    t.integer  "set_taggable_id"
    t.string   "set_taggable_type", :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "owned_tag_sets", :force => true do |t|
    t.integer  "tag_set_id"
    t.boolean  "visible",                                    :default => false, :null => false
    t.boolean  "nominated",                                  :default => false, :null => false
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",                                   :default => false, :null => false
    t.integer  "description_sanitizer_version", :limit => 2, :default => 0,     :null => false
    t.integer  "fandom_nomination_limit",                    :default => 0,     :null => false
    t.integer  "character_nomination_limit",                 :default => 0,     :null => false
    t.integer  "relationship_nomination_limit",              :default => 0,     :null => false
    t.integer  "freeform_nomination_limit",                  :default => 0,     :null => false
    t.boolean  "usable",                                     :default => false, :null => false
  end

  create_table "potential_match_settings", :force => true do |t|
    t.integer  "num_required_prompts",           :default => 1,     :null => false
    t.integer  "num_required_fandoms",           :default => 0,     :null => false
    t.integer  "num_required_characters",        :default => 0,     :null => false
    t.integer  "num_required_relationships",     :default => 0,     :null => false
    t.integer  "num_required_freeforms",         :default => 0,     :null => false
    t.integer  "num_required_categories",        :default => 0,     :null => false
    t.integer  "num_required_ratings",           :default => 0,     :null => false
    t.integer  "num_required_warnings",          :default => 0,     :null => false
    t.boolean  "include_optional_fandoms",       :default => false, :null => false
    t.boolean  "include_optional_characters",    :default => false, :null => false
    t.boolean  "include_optional_relationships", :default => false, :null => false
    t.boolean  "include_optional_freeforms",     :default => false, :null => false
    t.boolean  "include_optional_categories",    :default => false, :null => false
    t.boolean  "include_optional_ratings",       :default => false, :null => false
    t.boolean  "include_optional_warnings",      :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "potential_matches", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "offer_signup_id"
    t.integer  "request_signup_id"
    t.integer  "num_prompts_matched"
    t.boolean  "assigned",            :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "potential_prompt_matches", :force => true do |t|
    t.integer  "potential_match_id"
    t.integer  "offer_id"
    t.integer  "request_id"
    t.integer  "num_fandoms_matched"
    t.integer  "num_characters_matched"
    t.integer  "num_relationships_matched"
    t.integer  "num_freeforms_matched"
    t.integer  "num_categories_matched"
    t.integer  "num_ratings_matched"
    t.integer  "num_warnings_matched"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.boolean  "view_full_works",                   :default => false,                     :null => false
    t.string   "time_zone"
    t.boolean  "plain_text_skin",                   :default => false,                     :null => false
    t.boolean  "admin_emails_off",                  :default => false,                     :null => false
    t.boolean  "disable_work_skins",                :default => false,                     :null => false
    t.integer  "skin_id"
    t.boolean  "minimize_search_engines",           :default => false,                     :null => false
    t.boolean  "kudos_emails_off",                  :default => false,                     :null => false
    t.boolean  "disable_share_links",               :default => false,                     :null => false
    t.boolean  "banner_seen",                       :default => false,                     :null => false
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
    t.integer  "about_me_sanitizer_version", :limit => 2, :default => 0, :null => false
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "prompt_memes", :force => true do |t|
    t.integer  "prompt_restriction_id"
    t.integer  "request_restriction_id"
    t.integer  "requests_num_required",                                       :default => 1,     :null => false
    t.integer  "requests_num_allowed",                                        :default => 5,     :null => false
    t.boolean  "signup_open",                                                 :default => true,  :null => false
    t.datetime "signups_open_at"
    t.datetime "signups_close_at"
    t.datetime "assignments_due_at"
    t.datetime "works_reveal_at"
    t.datetime "authors_reveal_at"
    t.text     "signup_instructions_general"
    t.text     "signup_instructions_requests"
    t.string   "request_url_label"
    t.string   "request_description_label"
    t.string   "time_zone"
    t.integer  "signup_instructions_general_sanitizer_version",  :limit => 2, :default => 0,     :null => false
    t.integer  "signup_instructions_requests_sanitizer_version", :limit => 2, :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "anonymous",                                                   :default => false, :null => false
  end

  create_table "prompt_restrictions", :force => true do |t|
    t.integer  "tag_set_id"
    t.boolean  "optional_tags_allowed",            :default => false, :null => false
    t.boolean  "description_allowed",              :default => true,  :null => false
    t.boolean  "url_required",                     :default => false, :null => false
    t.integer  "fandom_num_required",              :default => 0,     :null => false
    t.integer  "category_num_required",            :default => 0,     :null => false
    t.integer  "rating_num_required",              :default => 0,     :null => false
    t.integer  "character_num_required",           :default => 0,     :null => false
    t.integer  "relationship_num_required",        :default => 0,     :null => false
    t.integer  "freeform_num_required",            :default => 0,     :null => false
    t.integer  "warning_num_required",             :default => 0,     :null => false
    t.integer  "fandom_num_allowed",               :default => 1,     :null => false
    t.integer  "category_num_allowed",             :default => 0,     :null => false
    t.integer  "rating_num_allowed",               :default => 0,     :null => false
    t.integer  "character_num_allowed",            :default => 1,     :null => false
    t.integer  "relationship_num_allowed",         :default => 1,     :null => false
    t.integer  "freeform_num_allowed",             :default => 0,     :null => false
    t.integer  "warning_num_allowed",              :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "description_required",             :default => false, :null => false
    t.boolean  "url_allowed",                      :default => false, :null => false
    t.boolean  "allow_any_fandom",                 :default => false, :null => false
    t.boolean  "allow_any_character",              :default => false, :null => false
    t.boolean  "allow_any_rating",                 :default => false, :null => false
    t.boolean  "allow_any_relationship",           :default => false, :null => false
    t.boolean  "allow_any_category",               :default => false, :null => false
    t.boolean  "allow_any_warning",                :default => false, :null => false
    t.boolean  "allow_any_freeform",               :default => false, :null => false
    t.boolean  "require_unique_fandom",            :default => false, :null => false
    t.boolean  "require_unique_character",         :default => false, :null => false
    t.boolean  "require_unique_rating",            :default => false, :null => false
    t.boolean  "require_unique_relationship",      :default => false, :null => false
    t.boolean  "require_unique_category",          :default => false, :null => false
    t.boolean  "require_unique_warning",           :default => false, :null => false
    t.boolean  "require_unique_freeform",          :default => false, :null => false
    t.boolean  "character_restrict_to_fandom",     :default => false, :null => false
    t.boolean  "relationship_restrict_to_fandom",  :default => false, :null => false
    t.boolean  "character_restrict_to_tag_set",    :default => false, :null => false
    t.boolean  "relationship_restrict_to_tag_set", :default => false, :null => false
    t.boolean  "title_required",                   :default => false, :null => false
    t.boolean  "title_allowed",                    :default => false, :null => false
  end

  create_table "prompts", :force => true do |t|
    t.integer  "collection_id"
    t.integer  "challenge_signup_id"
    t.integer  "pseud_id"
    t.integer  "tag_set_id"
    t.integer  "optional_tag_set_id"
    t.string   "title"
    t.string   "url"
    t.text     "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "description_sanitizer_version", :limit => 2, :default => 0,     :null => false
    t.boolean  "any_fandom",                                 :default => false, :null => false
    t.boolean  "any_character",                              :default => false, :null => false
    t.boolean  "any_rating",                                 :default => false, :null => false
    t.boolean  "any_relationship",                           :default => false, :null => false
    t.boolean  "any_category",                               :default => false, :null => false
    t.boolean  "any_warning",                                :default => false, :null => false
    t.boolean  "any_freeform",                               :default => false, :null => false
    t.boolean  "anonymous",                                  :default => false, :null => false
  end

  add_index "prompts", ["challenge_signup_id"], :name => "index_prompts_on_challenge_signup_id"
  add_index "prompts", ["collection_id"], :name => "index_prompts_on_collection_id"
  add_index "prompts", ["optional_tag_set_id"], :name => "index_prompts_on_optional_tag_set_id"
  add_index "prompts", ["tag_set_id"], :name => "index_prompts_on_tag_set_id"
  add_index "prompts", ["type"], :name => "index_prompts_on_type"

  create_table "pseuds", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",                                                          :null => false
    t.text     "description"
    t.boolean  "is_default",                                 :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.string   "icon_alt_text",                              :default => ""
    t.boolean  "delta",                                      :default => true
    t.integer  "description_sanitizer_version", :limit => 2, :default => 0,     :null => false
    t.string   "icon_comment_text",                          :default => ""
  end

  add_index "pseuds", ["name"], :name => "index_psueds_on_name"
  add_index "pseuds", ["user_id", "name"], :name => "index_pseuds_on_user_id_and_name"

  create_table "readings", :force => true do |t|
    t.integer  "major_version_read"
    t.integer  "minor_version_read"
    t.integer  "user_id"
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "last_viewed"
    t.integer  "view_count",         :default => 0
    t.boolean  "toread",             :default => false, :null => false
    t.boolean  "toskip",             :default => false, :null => false
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
    t.boolean  "translation", :default => false, :null => false
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

  create_table "searches", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "options"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "title",                                                     :null => false
    t.text     "summary"
    t.text     "notes"
    t.boolean  "hidden_by_admin",                        :default => false, :null => false
    t.boolean  "restricted",                             :default => true,  :null => false
    t.boolean  "complete",                               :default => false, :null => false
    t.integer  "summary_sanitizer_version", :limit => 2, :default => 0,     :null => false
    t.integer  "notes_sanitizer_version",   :limit => 2, :default => 0,     :null => false
  end

  create_table "set_taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "tag_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "set_taggings", ["tag_id"], :name => "index_set_taggings_on_tag_id"
  add_index "set_taggings", ["tag_set_id"], :name => "index_set_taggings_on_tag_set_id"

  create_table "skin_parents", :force => true do |t|
    t.integer  "child_skin_id"
    t.integer  "parent_skin_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skins", :force => true do |t|
    t.string   "title"
    t.integer  "author_id"
    t.text     "css"
    t.boolean  "public",                                     :default => false
    t.boolean  "official",                                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.string   "icon_alt_text",                              :default => ""
    t.integer  "margin"
    t.integer  "paragraph_gap"
    t.string   "font"
    t.integer  "base_em"
    t.string   "background_color"
    t.string   "foreground_color"
    t.text     "description"
    t.boolean  "rejected",                                   :default => false, :null => false
    t.string   "admin_note"
    t.integer  "description_sanitizer_version", :limit => 2, :default => 0,     :null => false
    t.string   "type"
    t.float    "paragraph_margin"
    t.string   "headercolor"
    t.string   "accent_color"
    t.string   "role"
    t.string   "media"
    t.string   "ie_condition"
    t.string   "filename"
    t.boolean  "do_not_upgrade",                             :default => false, :null => false
    t.boolean  "cached",                                     :default => false, :null => false
    t.boolean  "unusable",                                   :default => false, :null => false
    t.boolean  "featured",                                   :default => false, :null => false
    t.boolean  "in_chooser",                                 :default => false, :null => false
  end

  add_index "skins", ["author_id"], :name => "index_skins_on_author_id"
  add_index "skins", ["in_chooser"], :name => "index_skins_on_in_chooser"
  add_index "skins", ["public", "official"], :name => "index_skins_on_public_and_official"
  add_index "skins", ["title"], :name => "index_skins_on_title"
  add_index "skins", ["type"], :name => "index_skins_on_type"

  create_table "stat_counters", :force => true do |t|
    t.integer "work_id"
    t.integer "hit_count",       :default => 0, :null => false
    t.string  "last_visitor"
    t.integer "download_count",  :default => 0, :null => false
    t.integer "comments_count",  :default => 0, :null => false
    t.integer "kudos_count",     :default => 0, :null => false
    t.integer "bookmarks_count", :default => 0, :null => false
  end

  add_index "stat_counters", ["hit_count"], :name => "index_hit_counters_on_hit_count"
  add_index "stat_counters", ["work_id"], :name => "index_hit_counters_on_work_id", :unique => true

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "subscribable_id"
    t.string   "subscribable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["subscribable_id", "subscribable_type"], :name => "subscribable"
  add_index "subscriptions", ["user_id"], :name => "user_id"

  create_table "tag_nominations", :force => true do |t|
    t.string   "type"
    t.integer  "tag_set_nomination_id"
    t.integer  "fandom_nomination_id"
    t.string   "tagname"
    t.string   "parent_tagname"
    t.boolean  "approved",              :default => false, :null => false
    t.boolean  "rejected",              :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "canonical",             :default => false, :null => false
    t.boolean  "exists",                :default => false, :null => false
    t.boolean  "parented",              :default => false, :null => false
    t.string   "synonym"
  end

  create_table "tag_set_associations", :force => true do |t|
    t.integer  "owned_tag_set_id"
    t.integer  "tag_id"
    t.integer  "parent_tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tag_set_nominations", :force => true do |t|
    t.integer  "pseud_id"
    t.integer  "owned_tag_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tag_set_ownerships", :force => true do |t|
    t.integer  "pseud_id"
    t.integer  "owned_tag_set_id"
    t.boolean  "owner",            :default => false, :null => false
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
    t.string   "name",               :limit => 100, :default => ""
    t.boolean  "canonical",                         :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taggings_count",                    :default => 0
    t.boolean  "adult",                             :default => false
    t.string   "type"
    t.integer  "merger_id"
    t.boolean  "delta",                             :default => false
    t.integer  "last_wrangler_id"
    t.string   "last_wrangler_type"
    t.boolean  "unwrangleable",                     :default => false, :null => false
    t.string   "sortable_name",                     :default => "",    :null => false
  end

  add_index "tags", ["canonical"], :name => "index_tags_on_canonical"
  add_index "tags", ["created_at"], :name => "tag_created_at_index"
  add_index "tags", ["id", "type"], :name => "index_tags_on_id_and_type"
  add_index "tags", ["merger_id"], :name => "index_tags_on_merger_id"
  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true
  add_index "tags", ["sortable_name"], :name => "index_tags_on_sortable_name"
  add_index "tags", ["type"], :name => "index_tags_on_type"

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
    t.string   "email"
    t.string   "activation_code"
    t.string   "login"
    t.datetime "activated_at"
    t.string   "crypted_password"
    t.string   "salt"
    t.boolean  "recently_reset",                    :default => false, :null => false
    t.boolean  "suspended",                         :default => false, :null => false
    t.boolean  "banned",                            :default => false, :null => false
    t.integer  "invitation_id"
    t.datetime "suspended_until"
    t.boolean  "out_of_invites",                    :default => true,  :null => false
    t.string   "persistence_token",                                    :null => false
    t.integer  "failed_login_count"
  end

  add_index "users", ["activation_code"], :name => "index_users_on_activation_code"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "work_links", :force => true do |t|
    t.integer  "work_id"
    t.string   "url"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "work_links", ["work_id", "url"], :name => "work_links_work_id_url", :unique => true

  create_table "works", :force => true do |t|
    t.integer  "expected_number_of_chapters",              :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "major_version",                            :default => 1
    t.integer  "minor_version",                            :default => 0
    t.boolean  "posted",                                   :default => false, :null => false
    t.integer  "language_id"
    t.boolean  "restricted",                               :default => false, :null => false
    t.string   "title",                                                       :null => false
    t.text     "summary"
    t.text     "notes"
    t.integer  "word_count"
    t.boolean  "hidden_by_admin",                          :default => false, :null => false
    t.boolean  "delta",                                    :default => false
    t.datetime "revised_at"
    t.string   "authors_to_sort_on"
    t.string   "title_to_sort_on"
    t.boolean  "backdate",                                 :default => false, :null => false
    t.text     "endnotes"
    t.string   "imported_from_url"
    t.integer  "hit_count_old",                            :default => 0,     :null => false
    t.string   "last_visitor_old"
    t.boolean  "complete",                                 :default => false, :null => false
    t.integer  "summary_sanitizer_version",   :limit => 2, :default => 0,     :null => false
    t.integer  "notes_sanitizer_version",     :limit => 2, :default => 0,     :null => false
    t.integer  "endnotes_sanitizer_version",  :limit => 2, :default => 0,     :null => false
    t.integer  "work_skin_id"
    t.boolean  "in_anon_collection",                       :default => false, :null => false
    t.boolean  "in_unrevealed_collection",                 :default => false, :null => false
  end

  add_index "works", ["complete", "posted", "hidden_by_admin"], :name => "complete_works"
  add_index "works", ["delta"], :name => "index_works_on_delta"
  add_index "works", ["imported_from_url"], :name => "index_works_on_imported_from_url"
  add_index "works", ["language_id"], :name => "index_works_on_language_id"
  add_index "works", ["restricted", "posted", "hidden_by_admin"], :name => "visible_works"
  add_index "works", ["revised_at"], :name => "index_works_on_revised_at"

  create_table "wrangling_assignments", :force => true do |t|
    t.integer "user_id"
    t.integer "fandom_id"
  end

  add_index "wrangling_assignments", ["fandom_id"], :name => "wrangling_assignments_by_fandom_id"
  add_index "wrangling_assignments", ["user_id"], :name => "wrangling_assignments_by_user_id"

end
