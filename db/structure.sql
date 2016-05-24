CREATE TABLE `abuse_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `url` varchar(255) NOT NULL,
  `comment` text NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `comment_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `admin_activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `target_type` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `summary` text,
  `summary_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `admin_banners` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text,
  `content_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `banner_type` varchar(255) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `admin_post_taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_post_tag_id` int(11) DEFAULT NULL,
  `admin_post_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_post_taggings_on_admin_post_id` (`admin_post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `admin_post_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `admin_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `content_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `translated_post_id` int(11) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_posts_on_created_at` (`created_at`),
  KEY `index_admin_posts_on_post_id` (`translated_post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `admin_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_creation_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `invite_from_queue_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `invite_from_queue_number` bigint(20) DEFAULT NULL,
  `invite_from_queue_frequency` mediumint(9) DEFAULT NULL,
  `days_to_purge_unactivated` mediumint(9) DEFAULT NULL,
  `last_updated_by` bigint(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `invite_from_queue_at` datetime DEFAULT '2009-11-07 21:27:21',
  `suspend_filter_counts` tinyint(1) DEFAULT '0',
  `suspend_filter_counts_at` datetime DEFAULT NULL,
  `enable_test_caching` tinyint(1) DEFAULT '0',
  `cache_expiration` bigint(20) DEFAULT '10',
  `tag_wrangling_off` tinyint(1) NOT NULL DEFAULT '0',
  `guest_downloading_off` tinyint(1) NOT NULL DEFAULT '0',
  `default_skin_id` int(11) DEFAULT NULL,
  `stats_updated_at` datetime DEFAULT NULL,
  `disable_filtering` tinyint(1) NOT NULL DEFAULT '0',
  `request_invite_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `creation_requires_invite` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_admin_settings_on_last_updated_by` (`last_updated_by`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `login` varchar(255) DEFAULT NULL,
  `crypted_password` varchar(255) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  `persistence_token` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `api_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `access_token` varchar(255) NOT NULL,
  `banned` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_api_keys_on_access_token` (`access_token`),
  UNIQUE KEY `index_api_keys_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `archive_faq_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `archive_faq_id` int(11) DEFAULT NULL,
  `locale` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_archive_faq_translations_on_archive_faq_id` (`archive_faq_id`),
  KEY `index_archive_faq_translations_on_locale` (`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `archive_faqs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `position` int(11) DEFAULT '1',
  `slug` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_archive_faqs_on_slug` (`slug`),
  KEY `index_archive_faqs_on_position` (`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `audits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `auditable_id` int(11) DEFAULT NULL,
  `auditable_type` varchar(255) DEFAULT NULL,
  `associated_id` int(11) DEFAULT NULL,
  `associated_type` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_type` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `audited_changes` text,
  `version` int(11) DEFAULT '0',
  `comment` varchar(255) DEFAULT NULL,
  `remote_address` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `associated_index` (`associated_id`,`associated_type`),
  KEY `auditable_index` (`auditable_id`,`auditable_type`),
  KEY `index_audits_on_created_at` (`created_at`),
  KEY `user_index` (`user_id`,`user_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `bookmarks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `bookmarkable_type` varchar(15) NOT NULL,
  `bookmarkable_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `notes` text,
  `private` tinyint(1) DEFAULT '0',
  `updated_at` datetime DEFAULT NULL,
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `pseud_id` int(11) NOT NULL,
  `rec` tinyint(1) NOT NULL DEFAULT '0',
  `delta` tinyint(1) DEFAULT '1',
  `notes_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_bookmarkable_pseud` (`bookmarkable_id`,`bookmarkable_type`,`pseud_id`),
  KEY `index_bookmarks_on_private_and_hidden_by_admin_and_created_at` (`private`,`hidden_by_admin`,`created_at`),
  KEY `index_bookmarks_on_pseud_id` (`pseud_id`),
  KEY `fk_bookmarks_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `challenge_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_id` int(11) DEFAULT NULL,
  `creation_id` int(11) DEFAULT NULL,
  `creation_type` varchar(255) DEFAULT NULL,
  `offer_signup_id` int(11) DEFAULT NULL,
  `request_signup_id` int(11) DEFAULT NULL,
  `pinch_hitter_id` int(11) DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `fulfilled_at` datetime DEFAULT NULL,
  `defaulted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pinch_request_signup_id` int(11) DEFAULT NULL,
  `covered_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_challenge_assignments_on_collection_id` (`collection_id`),
  KEY `assignments_on_creation_id` (`creation_id`),
  KEY `assignments_on_creation_type` (`creation_type`),
  KEY `assignments_on_defaulted_at` (`defaulted_at`),
  KEY `assignments_on_offer_signup_id` (`offer_signup_id`),
  KEY `assignments_on_pinch_hitter_id` (`pinch_hitter_id`),
  KEY `assignments_on_offer_sent_at` (`sent_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `challenge_claims` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_id` int(11) DEFAULT NULL,
  `creation_id` int(11) DEFAULT NULL,
  `creation_type` varchar(255) DEFAULT NULL,
  `request_signup_id` int(11) DEFAULT NULL,
  `request_prompt_id` int(11) DEFAULT NULL,
  `claiming_user_id` int(11) DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `fulfilled_at` datetime DEFAULT NULL,
  `defaulted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_challenge_claims_on_claiming_user_id` (`claiming_user_id`),
  KEY `index_challenge_claims_on_collection_id` (`collection_id`),
  KEY `creations` (`creation_id`,`creation_type`),
  KEY `index_challenge_claims_on_request_signup_id` (`request_signup_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `challenge_signups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_id` int(11) DEFAULT NULL,
  `pseud_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `assigned_as_request` tinyint(1) DEFAULT '0',
  `assigned_as_offer` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_challenge_signups_on_collection_id` (`collection_id`),
  KEY `signups_on_pseud_id` (`pseud_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `chapters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` longtext NOT NULL,
  `position` int(11) DEFAULT '1',
  `work_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `posted` tinyint(1) NOT NULL DEFAULT '0',
  `title` varchar(255) DEFAULT NULL,
  `notes` text,
  `summary` text,
  `word_count` int(11) DEFAULT NULL,
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `published_at` date DEFAULT NULL,
  `endnotes` text,
  `content_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `notes_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `summary_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `endnotes_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_chapters_on_work_id` (`work_id`),
  KEY `works_chapter_index` (`work_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `collection_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `item_type` varchar(255) DEFAULT 'Work',
  `user_approval_status` tinyint(4) NOT NULL DEFAULT '0',
  `collection_approval_status` tinyint(4) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `anonymous` tinyint(1) NOT NULL DEFAULT '0',
  `unrevealed` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `by collection and item` (`collection_id`,`item_id`,`item_type`),
  KEY `collection_items_anonymous` (`anonymous`),
  KEY `index_collection_items_approval_status` (`collection_id`,`user_approval_status`,`collection_approval_status`),
  KEY `collection_items_item_id` (`item_id`),
  KEY `collection_items_unrevealed` (`unrevealed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `collection_participants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_id` int(11) DEFAULT NULL,
  `pseud_id` int(11) DEFAULT NULL,
  `participant_role` varchar(255) NOT NULL DEFAULT 'None',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `by collection and pseud` (`collection_id`,`pseud_id`),
  KEY `participants_by_collection_and_role` (`collection_id`,`participant_role`),
  KEY `participants_pseud_id` (`pseud_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `collection_preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `moderated` tinyint(1) NOT NULL DEFAULT '0',
  `closed` tinyint(1) NOT NULL DEFAULT '0',
  `unrevealed` tinyint(1) NOT NULL DEFAULT '0',
  `anonymous` tinyint(1) NOT NULL DEFAULT '0',
  `gift_exchange` tinyint(1) NOT NULL DEFAULT '0',
  `show_random` tinyint(1) NOT NULL DEFAULT '0',
  `prompt_meme` tinyint(1) NOT NULL DEFAULT '0',
  `email_notify` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_collection_preferences_on_collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `collection_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_id` int(11) DEFAULT NULL,
  `intro` mediumtext,
  `faq` mediumtext,
  `rules` mediumtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `gift_notification` text,
  `intro_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `faq_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `rules_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `assignment_notification` text,
  PRIMARY KEY (`id`),
  KEY `index_collection_profiles_on_collection_id` (`collection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `header_image_url` varchar(255) DEFAULT NULL,
  `description` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `challenge_id` int(11) DEFAULT NULL,
  `challenge_type` varchar(255) DEFAULT NULL,
  `icon_file_name` varchar(255) DEFAULT NULL,
  `icon_content_type` varchar(255) DEFAULT NULL,
  `icon_file_size` int(11) DEFAULT NULL,
  `icon_updated_at` datetime DEFAULT NULL,
  `description_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `icon_alt_text` varchar(255) DEFAULT '',
  `icon_comment_text` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `index_collections_on_name` (`name`),
  KEY `index_collections_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pseud_id` int(11) DEFAULT NULL,
  `content` text NOT NULL,
  `depth` int(11) DEFAULT NULL,
  `threaded_left` int(11) DEFAULT NULL,
  `threaded_right` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `commentable_id` int(11) DEFAULT NULL,
  `commentable_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `thread` int(11) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `approved` tinyint(1) NOT NULL DEFAULT '0',
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `edited_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) DEFAULT NULL,
  `content_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `unreviewed` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_comments_commentable` (`commentable_id`,`commentable_type`),
  KEY `index_comments_parent` (`parent_id`,`parent_type`),
  KEY `index_comments_on_pseud_id` (`pseud_id`),
  KEY `comments_by_thread` (`thread`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `common_taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `common_tag_id` int(11) NOT NULL,
  `filterable_id` int(11) NOT NULL,
  `filterable_type` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_common_tags` (`common_tag_id`,`filterable_type`,`filterable_id`),
  KEY `index_common_taggings_on_filterable_id` (`filterable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `creatorships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `creation_id` int(11) DEFAULT NULL,
  `creation_type` varchar(100) DEFAULT NULL,
  `pseud_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `creation_id_creation_type_pseud_id` (`creation_id`,`creation_type`,`pseud_id`),
  KEY `index_creatorships_pseud` (`pseud_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text,
  `last_error` text,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_failed_at` (`failed_at`),
  KEY `delayed_jobs_locked_at` (`locked_at`),
  KEY `delayed_jobs_locked_by` (`locked_by`),
  KEY `delayed_jobs_run_at` (`run_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `external_author_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `external_author_id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_external_author_names_on_external_author_id` (`external_author_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `external_authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `is_claimed` tinyint(1) NOT NULL DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `do_not_email` tinyint(1) NOT NULL DEFAULT '0',
  `do_not_import` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_external_authors_on_email` (`email`),
  KEY `index_external_authors_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `external_creatorships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `creation_id` int(11) DEFAULT NULL,
  `creation_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `archivist_id` int(11) DEFAULT NULL,
  `external_author_name_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_external_creatorships_on_archivist_id` (`archivist_id`),
  KEY `index_external_creatorships_on_creation_id_and_creation_type` (`creation_id`,`creation_type`),
  KEY `index_external_creatorships_on_external_author_name_id` (`external_author_name_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `external_works` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `dead` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `summary` text,
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `summary_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `language_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fannish_next_of_kins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `kin_id` int(11) DEFAULT NULL,
  `kin_email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_fannish_next_of_kins_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `favorite_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `tag_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_favorite_tags_on_user_id_and_tag_id` (`user_id`,`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `comment` text NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `summary` varchar(255) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `comment_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `summary_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `approved` tinyint(1) NOT NULL DEFAULT '0',
  `ip_address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `filter_counts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filter_id` bigint(20) NOT NULL,
  `public_works_count` bigint(20) DEFAULT '0',
  `unhidden_works_count` bigint(20) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_filter_counts_on_filter_id` (`filter_id`),
  KEY `index_public_works_count` (`public_works_count`),
  KEY `index_unhidden_works_count` (`unhidden_works_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `filter_taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filter_id` bigint(20) NOT NULL,
  `filterable_id` bigint(20) NOT NULL,
  `filterable_type` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `inherited` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_filter_taggings_on_filter_id_and_filterable_type` (`filter_id`,`filterable_type`),
  KEY `index_filter_taggings_filterable` (`filterable_id`,`filterable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `gift_exchanges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `request_restriction_id` int(11) DEFAULT NULL,
  `offer_restriction_id` int(11) DEFAULT NULL,
  `requests_num_required` int(11) NOT NULL DEFAULT '1',
  `offers_num_required` int(11) NOT NULL DEFAULT '1',
  `requests_num_allowed` int(11) NOT NULL DEFAULT '1',
  `offers_num_allowed` int(11) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `signup_instructions_general` text,
  `signup_instructions_requests` text,
  `signup_instructions_offers` text,
  `signup_open` tinyint(1) NOT NULL DEFAULT '0',
  `signups_open_at` datetime DEFAULT NULL,
  `signups_close_at` datetime DEFAULT NULL,
  `assignments_due_at` datetime DEFAULT NULL,
  `works_reveal_at` datetime DEFAULT NULL,
  `authors_reveal_at` datetime DEFAULT NULL,
  `prompt_restriction_id` int(11) DEFAULT NULL,
  `request_url_label` varchar(255) DEFAULT NULL,
  `request_description_label` varchar(255) DEFAULT NULL,
  `offer_url_label` varchar(255) DEFAULT NULL,
  `offer_description_label` varchar(255) DEFAULT NULL,
  `time_zone` varchar(255) DEFAULT NULL,
  `potential_match_settings_id` int(11) DEFAULT NULL,
  `assignments_sent_at` datetime DEFAULT NULL,
  `signup_instructions_general_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `signup_instructions_requests_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `signup_instructions_offers_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `requests_summary_visible` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `gifts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `work_id` int(11) DEFAULT NULL,
  `recipient_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pseud_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gifts_on_pseud_id` (`pseud_id`),
  KEY `index_gifts_on_recipient_name` (`recipient_name`),
  KEY `index_gifts_on_work_id` (`work_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `inbox_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `feedback_comment_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `replied_to` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_inbox_comments_on_feedback_comment_id` (`feedback_comment_id`),
  KEY `index_inbox_comments_on_read_and_user_id` (`read`,`user_id`),
  KEY `index_inbox_comments_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `invitations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `creator_id` int(11) DEFAULT NULL,
  `invitee_email` varchar(255) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `used` tinyint(1) NOT NULL DEFAULT '0',
  `invitee_id` int(11) DEFAULT NULL,
  `invitee_type` varchar(255) DEFAULT NULL,
  `creator_type` varchar(255) DEFAULT NULL,
  `redeemed_at` datetime DEFAULT NULL,
  `from_queue` tinyint(1) NOT NULL DEFAULT '0',
  `external_author_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invitations_on_creator_id_and_creator_type` (`creator_id`,`creator_type`),
  KEY `index_invitations_on_external_author_id` (`external_author_id`),
  KEY `index_invitations_on_invitee_id_and_invitee_type` (`invitee_id`,`invitee_type`),
  KEY `index_invitations_on_token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `invite_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invite_requests_on_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `known_issues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `content_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `kudos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pseud_id` int(11) DEFAULT NULL,
  `commentable_id` int(11) DEFAULT NULL,
  `commentable_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_kudos_on_commentable_id_and_commentable_type_and_pseud_id` (`commentable_id`,`commentable_type`,`pseud_id`),
  KEY `index_kudos_on_ip_address` (`ip_address`),
  KEY `index_kudos_on_pseud_id` (`pseud_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `short` varchar(4) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_languages_on_short` (`short`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `locales` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `iso` varchar(255) DEFAULT NULL,
  `short` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `main` tinyint(1) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `language_id` int(11) NOT NULL,
  `interface_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `email_enabled` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_locales_on_iso` (`iso`),
  KEY `index_locales_on_language_id` (`language_id`),
  KEY `index_locales_on_short` (`short`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `log_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  `action` tinyint(4) DEFAULT NULL,
  `note` text NOT NULL,
  `enddate` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `note_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_log_items_on_admin_id` (`admin_id`),
  KEY `index_log_items_on_role_id` (`role_id`),
  KEY `index_log_items_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `meta_taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meta_tag_id` bigint(20) NOT NULL,
  `sub_tag_id` bigint(20) NOT NULL,
  `direct` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_meta_taggings_on_meta_tag_id` (`meta_tag_id`),
  KEY `index_meta_taggings_on_sub_tag_id` (`sub_tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `open_id_authentication_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `issued` int(11) DEFAULT NULL,
  `lifetime` int(11) DEFAULT NULL,
  `handle` varchar(255) DEFAULT NULL,
  `assoc_type` varchar(255) DEFAULT NULL,
  `server_url` blob,
  `secret` blob,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `open_id_authentication_nonces` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `timestamp` int(11) NOT NULL,
  `server_url` varchar(255) DEFAULT NULL,
  `salt` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `owned_set_taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owned_tag_set_id` int(11) DEFAULT NULL,
  `set_taggable_id` int(11) DEFAULT NULL,
  `set_taggable_type` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `owned_tag_sets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_set_id` int(11) DEFAULT NULL,
  `visible` tinyint(1) NOT NULL DEFAULT '0',
  `nominated` tinyint(1) NOT NULL DEFAULT '0',
  `title` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `featured` tinyint(1) NOT NULL DEFAULT '0',
  `description_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `fandom_nomination_limit` int(11) NOT NULL DEFAULT '0',
  `character_nomination_limit` int(11) NOT NULL DEFAULT '0',
  `relationship_nomination_limit` int(11) NOT NULL DEFAULT '0',
  `freeform_nomination_limit` int(11) NOT NULL DEFAULT '0',
  `usable` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `potential_match_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `num_required_prompts` int(11) NOT NULL DEFAULT '1',
  `num_required_fandoms` int(11) NOT NULL DEFAULT '0',
  `num_required_characters` int(11) NOT NULL DEFAULT '0',
  `num_required_relationships` int(11) NOT NULL DEFAULT '0',
  `num_required_freeforms` int(11) NOT NULL DEFAULT '0',
  `num_required_categories` int(11) NOT NULL DEFAULT '0',
  `num_required_ratings` int(11) NOT NULL DEFAULT '0',
  `num_required_warnings` int(11) NOT NULL DEFAULT '0',
  `include_optional_fandoms` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_characters` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_relationships` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_freeforms` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_categories` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_ratings` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_warnings` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `potential_matches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_id` int(11) DEFAULT NULL,
  `offer_signup_id` int(11) DEFAULT NULL,
  `request_signup_id` int(11) DEFAULT NULL,
  `num_prompts_matched` int(11) DEFAULT NULL,
  `assigned` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_potential_matches_on_collection_id` (`collection_id`),
  KEY `index_potential_matches_on_offer_signup_id` (`offer_signup_id`),
  KEY `index_potential_matches_on_request_signup_id` (`request_signup_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `potential_prompt_matches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `potential_match_id` int(11) DEFAULT NULL,
  `offer_id` int(11) DEFAULT NULL,
  `request_id` int(11) DEFAULT NULL,
  `num_fandoms_matched` int(11) DEFAULT NULL,
  `num_characters_matched` int(11) DEFAULT NULL,
  `num_relationships_matched` int(11) DEFAULT NULL,
  `num_freeforms_matched` int(11) DEFAULT NULL,
  `num_categories_matched` int(11) DEFAULT NULL,
  `num_ratings_matched` int(11) DEFAULT NULL,
  `num_warnings_matched` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_potential_prompt_matches_on_offer_id` (`offer_id`),
  KEY `index_potential_prompt_matches_on_potential_match_id` (`potential_match_id`),
  KEY `index_potential_prompt_matches_on_request_id` (`request_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `history_enabled` tinyint(1) DEFAULT '1',
  `email_visible` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `date_of_birth_visible` tinyint(1) DEFAULT '0',
  `edit_emails_off` tinyint(1) NOT NULL DEFAULT '0',
  `comment_emails_off` tinyint(1) NOT NULL DEFAULT '0',
  `adult` tinyint(1) DEFAULT '0',
  `hide_warnings` tinyint(1) NOT NULL DEFAULT '0',
  `comment_inbox_off` tinyint(1) DEFAULT '0',
  `comment_copy_to_self_off` tinyint(1) NOT NULL DEFAULT '1',
  `work_title_format` varchar(255) DEFAULT 'TITLE - AUTHOR - FANDOM',
  `hide_freeform` tinyint(1) NOT NULL DEFAULT '0',
  `first_login` tinyint(1) DEFAULT '1',
  `automatically_approve_collections` tinyint(1) NOT NULL DEFAULT '0',
  `collection_emails_off` tinyint(1) NOT NULL DEFAULT '0',
  `collection_inbox_off` tinyint(1) NOT NULL DEFAULT '0',
  `hide_private_hit_count` tinyint(1) NOT NULL DEFAULT '0',
  `hide_public_hit_count` tinyint(1) NOT NULL DEFAULT '0',
  `recipient_emails_off` tinyint(1) NOT NULL DEFAULT '0',
  `hide_all_hit_counts` tinyint(1) NOT NULL DEFAULT '0',
  `view_full_works` tinyint(1) NOT NULL DEFAULT '0',
  `time_zone` varchar(255) DEFAULT NULL,
  `plain_text_skin` tinyint(1) NOT NULL DEFAULT '0',
  `admin_emails_off` tinyint(1) NOT NULL DEFAULT '0',
  `disable_work_skins` tinyint(1) NOT NULL DEFAULT '0',
  `skin_id` int(11) DEFAULT NULL,
  `minimize_search_engines` tinyint(1) NOT NULL DEFAULT '0',
  `kudos_emails_off` tinyint(1) NOT NULL DEFAULT '0',
  `disable_share_links` tinyint(1) NOT NULL DEFAULT '0',
  `banner_seen` tinyint(1) NOT NULL DEFAULT '0',
  `preferred_locale` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_preferences_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `about_me` text,
  `date_of_birth` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `about_me_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_profiles_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `prompt_memes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prompt_restriction_id` int(11) DEFAULT NULL,
  `request_restriction_id` int(11) DEFAULT NULL,
  `requests_num_required` int(11) NOT NULL DEFAULT '1',
  `requests_num_allowed` int(11) NOT NULL DEFAULT '5',
  `signup_open` tinyint(1) NOT NULL DEFAULT '1',
  `signups_open_at` datetime DEFAULT NULL,
  `signups_close_at` datetime DEFAULT NULL,
  `assignments_due_at` datetime DEFAULT NULL,
  `works_reveal_at` datetime DEFAULT NULL,
  `authors_reveal_at` datetime DEFAULT NULL,
  `signup_instructions_general` text,
  `signup_instructions_requests` text,
  `request_url_label` varchar(255) DEFAULT NULL,
  `request_description_label` varchar(255) DEFAULT NULL,
  `time_zone` varchar(255) DEFAULT NULL,
  `signup_instructions_general_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `signup_instructions_requests_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `anonymous` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `prompt_restrictions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_set_id` int(11) DEFAULT NULL,
  `optional_tags_allowed` tinyint(1) NOT NULL DEFAULT '0',
  `description_allowed` tinyint(1) NOT NULL DEFAULT '1',
  `url_required` tinyint(1) NOT NULL DEFAULT '0',
  `fandom_num_required` int(11) NOT NULL DEFAULT '0',
  `category_num_required` int(11) NOT NULL DEFAULT '0',
  `rating_num_required` int(11) NOT NULL DEFAULT '0',
  `character_num_required` int(11) NOT NULL DEFAULT '0',
  `relationship_num_required` int(11) NOT NULL DEFAULT '0',
  `freeform_num_required` int(11) NOT NULL DEFAULT '0',
  `warning_num_required` int(11) NOT NULL DEFAULT '0',
  `fandom_num_allowed` int(11) NOT NULL DEFAULT '1',
  `category_num_allowed` int(11) NOT NULL DEFAULT '0',
  `rating_num_allowed` int(11) NOT NULL DEFAULT '0',
  `character_num_allowed` int(11) NOT NULL DEFAULT '1',
  `relationship_num_allowed` int(11) NOT NULL DEFAULT '1',
  `freeform_num_allowed` int(11) NOT NULL DEFAULT '0',
  `warning_num_allowed` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `description_required` tinyint(1) NOT NULL DEFAULT '0',
  `url_allowed` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_fandom` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_character` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_rating` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_relationship` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_category` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_warning` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_freeform` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_fandom` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_character` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_rating` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_relationship` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_category` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_warning` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_freeform` tinyint(1) NOT NULL DEFAULT '0',
  `character_restrict_to_fandom` tinyint(1) NOT NULL DEFAULT '0',
  `relationship_restrict_to_fandom` tinyint(1) NOT NULL DEFAULT '0',
  `character_restrict_to_tag_set` tinyint(1) NOT NULL DEFAULT '0',
  `relationship_restrict_to_tag_set` tinyint(1) NOT NULL DEFAULT '0',
  `title_required` tinyint(1) NOT NULL DEFAULT '0',
  `title_allowed` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `prompts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `collection_id` int(11) DEFAULT NULL,
  `challenge_signup_id` int(11) DEFAULT NULL,
  `pseud_id` int(11) DEFAULT NULL,
  `tag_set_id` int(11) DEFAULT NULL,
  `optional_tag_set_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `description` text,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `description_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `any_fandom` tinyint(1) NOT NULL DEFAULT '0',
  `any_character` tinyint(1) NOT NULL DEFAULT '0',
  `any_rating` tinyint(1) NOT NULL DEFAULT '0',
  `any_relationship` tinyint(1) NOT NULL DEFAULT '0',
  `any_category` tinyint(1) NOT NULL DEFAULT '0',
  `any_warning` tinyint(1) NOT NULL DEFAULT '0',
  `any_freeform` tinyint(1) NOT NULL DEFAULT '0',
  `anonymous` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_prompts_on_challenge_signup_id` (`challenge_signup_id`),
  KEY `index_prompts_on_collection_id` (`collection_id`),
  KEY `index_prompts_on_optional_tag_set_id` (`optional_tag_set_id`),
  KEY `index_prompts_on_tag_set_id` (`tag_set_id`),
  KEY `index_prompts_on_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `pseuds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `icon_file_name` varchar(255) DEFAULT NULL,
  `icon_content_type` varchar(255) DEFAULT NULL,
  `icon_file_size` int(11) DEFAULT NULL,
  `icon_updated_at` datetime DEFAULT NULL,
  `icon_alt_text` varchar(255) DEFAULT '',
  `delta` tinyint(1) DEFAULT '1',
  `description_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `icon_comment_text` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `index_psueds_on_name` (`name`),
  KEY `index_pseuds_on_user_id_and_name` (`user_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `question_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL,
  `locale` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `question` varchar(255) DEFAULT NULL,
  `content` text,
  `content_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `screencast_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_question_translations_on_locale` (`locale`),
  KEY `index_question_translations_on_question_id` (`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `archive_faq_id` int(11) DEFAULT NULL,
  `question` varchar(255) DEFAULT NULL,
  `content` text,
  `anchor` varchar(255) DEFAULT NULL,
  `screencast` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `position` int(11) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_questions_on_archive_faq_id_and_position` (`archive_faq_id`,`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `readings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `major_version_read` int(11) DEFAULT NULL,
  `minor_version_read` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `work_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_viewed` datetime DEFAULT NULL,
  `view_count` int(11) DEFAULT '0',
  `toread` tinyint(1) NOT NULL DEFAULT '0',
  `toskip` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_readings_on_user_id` (`user_id`),
  KEY `index_readings_on_work_id` (`work_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `related_works` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `parent_type` varchar(255) DEFAULT NULL,
  `work_id` int(11) DEFAULT NULL,
  `reciprocal` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `translation` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_related_works_on_parent_id_and_parent_type` (`parent_id`,`parent_type`),
  KEY `index_related_works_on_work_id` (`work_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) DEFAULT NULL,
  `authorizable_type` varchar(40) DEFAULT NULL,
  `authorizable_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_roles_on_authorizable_id_and_authorizable_type` (`authorizable_id`,`authorizable_type`),
  KEY `index_roles_on_authorizable_type` (`authorizable_type`),
  KEY `index_roles_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `roles_users` (
  `user_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  KEY `index_roles_users_on_role_id_and_user_id` (`role_id`,`user_id`),
  KEY `index_roles_users_on_user_id_and_role_id` (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `saved_works` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `work_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_saved_works_on_user_id_and_work_id` (`user_id`,`work_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `searches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `options` text,
  `type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `serial_works` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `series_id` int(11) DEFAULT NULL,
  `work_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_serial_works_on_series_id` (`series_id`),
  KEY `index_serial_works_on_work_id` (`work_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `series` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `summary` text,
  `notes` text,
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `restricted` tinyint(1) NOT NULL DEFAULT '1',
  `complete` tinyint(1) NOT NULL DEFAULT '0',
  `summary_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `notes_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `set_taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `tag_set_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_set_taggings_on_tag_id` (`tag_id`),
  KEY `index_set_taggings_on_tag_set_id` (`tag_set_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `skin_parents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `child_skin_id` int(11) DEFAULT NULL,
  `parent_skin_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `skins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `author_id` int(11) DEFAULT NULL,
  `css` text,
  `public` tinyint(1) DEFAULT '0',
  `official` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `icon_file_name` varchar(255) DEFAULT NULL,
  `icon_content_type` varchar(255) DEFAULT NULL,
  `icon_file_size` int(11) DEFAULT NULL,
  `icon_updated_at` datetime DEFAULT NULL,
  `icon_alt_text` varchar(255) DEFAULT '',
  `margin` int(11) DEFAULT NULL,
  `paragraph_gap` int(11) DEFAULT NULL,
  `font` varchar(255) DEFAULT NULL,
  `base_em` int(11) DEFAULT NULL,
  `background_color` varchar(255) DEFAULT NULL,
  `foreground_color` varchar(255) DEFAULT NULL,
  `description` text,
  `rejected` tinyint(1) NOT NULL DEFAULT '0',
  `admin_note` varchar(255) DEFAULT NULL,
  `description_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `type` varchar(255) DEFAULT NULL,
  `paragraph_margin` float DEFAULT NULL,
  `headercolor` varchar(255) DEFAULT NULL,
  `accent_color` varchar(255) DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `media` varchar(255) DEFAULT NULL,
  `ie_condition` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `do_not_upgrade` tinyint(1) NOT NULL DEFAULT '0',
  `cached` tinyint(1) NOT NULL DEFAULT '0',
  `unusable` tinyint(1) NOT NULL DEFAULT '0',
  `featured` tinyint(1) NOT NULL DEFAULT '0',
  `in_chooser` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_skins_on_author_id` (`author_id`),
  KEY `index_skins_on_in_chooser` (`in_chooser`),
  KEY `index_skins_on_public_and_official` (`public`,`official`),
  KEY `index_skins_on_title` (`title`),
  KEY `index_skins_on_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `stat_counters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `work_id` int(11) DEFAULT NULL,
  `hit_count` int(11) NOT NULL DEFAULT '0',
  `last_visitor` varchar(255) DEFAULT NULL,
  `download_count` int(11) NOT NULL DEFAULT '0',
  `comments_count` int(11) NOT NULL DEFAULT '0',
  `kudos_count` int(11) NOT NULL DEFAULT '0',
  `bookmarks_count` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_hit_counters_on_work_id` (`work_id`),
  KEY `index_hit_counters_on_hit_count` (`hit_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `subscribable_id` int(11) DEFAULT NULL,
  `subscribable_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subscribable` (`subscribable_id`,`subscribable_type`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tag_nominations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `tag_set_nomination_id` int(11) DEFAULT NULL,
  `fandom_nomination_id` int(11) DEFAULT NULL,
  `tagname` varchar(255) DEFAULT NULL,
  `parent_tagname` varchar(255) DEFAULT NULL,
  `approved` tinyint(1) NOT NULL DEFAULT '0',
  `rejected` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `canonical` tinyint(1) NOT NULL DEFAULT '0',
  `exists` tinyint(1) NOT NULL DEFAULT '0',
  `parented` tinyint(1) NOT NULL DEFAULT '0',
  `synonym` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tag_set_associations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owned_tag_set_id` int(11) DEFAULT NULL,
  `tag_id` int(11) DEFAULT NULL,
  `parent_tag_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tag_set_nominations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pseud_id` int(11) DEFAULT NULL,
  `owned_tag_set_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tag_set_ownerships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pseud_id` int(11) DEFAULT NULL,
  `owned_tag_set_id` int(11) DEFAULT NULL,
  `owner` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tag_sets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tagger_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) NOT NULL,
  `taggable_type` varchar(100) DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `tagger_type` varchar(100) DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_taggings_polymorphic` (`tagger_id`,`tagger_type`,`taggable_id`,`taggable_type`),
  KEY `index_taggings_taggable` (`taggable_id`,`taggable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT '',
  `canonical` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `taggings_count` int(11) DEFAULT '0',
  `adult` tinyint(1) DEFAULT '0',
  `type` varchar(255) DEFAULT NULL,
  `merger_id` int(11) DEFAULT NULL,
  `delta` tinyint(1) DEFAULT '0',
  `last_wrangler_id` int(11) DEFAULT NULL,
  `last_wrangler_type` varchar(255) DEFAULT NULL,
  `unwrangleable` tinyint(1) NOT NULL DEFAULT '0',
  `sortable_name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tags_on_name` (`name`),
  KEY `index_tags_on_canonical` (`canonical`),
  KEY `tag_created_at_index` (`created_at`),
  KEY `index_tags_on_id_and_type` (`id`,`type`),
  KEY `index_tags_on_merger_id` (`merger_id`),
  KEY `index_tags_on_sortable_name` (`sortable_name`),
  KEY `index_tags_on_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_invite_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `reason` text,
  `granted` tinyint(1) NOT NULL DEFAULT '0',
  `handled` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_invite_requests_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `activation_code` varchar(255) DEFAULT NULL,
  `login` varchar(255) DEFAULT NULL,
  `activated_at` datetime DEFAULT NULL,
  `crypted_password` varchar(255) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  `recently_reset` tinyint(1) NOT NULL DEFAULT '0',
  `suspended` tinyint(1) NOT NULL DEFAULT '0',
  `banned` tinyint(1) NOT NULL DEFAULT '0',
  `invitation_id` int(11) DEFAULT NULL,
  `suspended_until` datetime DEFAULT NULL,
  `out_of_invites` tinyint(1) NOT NULL DEFAULT '1',
  `persistence_token` varchar(255) NOT NULL,
  `failed_login_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_login` (`login`),
  KEY `index_users_on_activation_code` (`activation_code`),
  KEY `index_users_on_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `work_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `work_id` int(11) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `work_links_work_id_url` (`work_id`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `works` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expected_number_of_chapters` int(11) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `major_version` int(11) DEFAULT '1',
  `minor_version` int(11) DEFAULT '0',
  `posted` tinyint(1) NOT NULL DEFAULT '0',
  `language_id` int(11) DEFAULT NULL,
  `restricted` tinyint(1) NOT NULL DEFAULT '0',
  `title` varchar(255) NOT NULL,
  `summary` text,
  `notes` text,
  `word_count` int(11) DEFAULT NULL,
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `delta` tinyint(1) DEFAULT '0',
  `revised_at` datetime DEFAULT NULL,
  `authors_to_sort_on` varchar(255) DEFAULT NULL,
  `title_to_sort_on` varchar(255) DEFAULT NULL,
  `backdate` tinyint(1) NOT NULL DEFAULT '0',
  `endnotes` text,
  `imported_from_url` varchar(255) DEFAULT NULL,
  `hit_count_old` int(11) NOT NULL DEFAULT '0',
  `last_visitor_old` varchar(255) DEFAULT NULL,
  `complete` tinyint(1) NOT NULL DEFAULT '0',
  `summary_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `notes_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `endnotes_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  `work_skin_id` int(11) DEFAULT NULL,
  `in_anon_collection` tinyint(1) NOT NULL DEFAULT '0',
  `in_unrevealed_collection` tinyint(1) NOT NULL DEFAULT '0',
  `anon_commenting_disabled` tinyint(1) NOT NULL DEFAULT '0',
  `ip_address` varchar(255) DEFAULT NULL,
  `spam` tinyint(1) NOT NULL DEFAULT '0',
  `spam_checked_at` datetime DEFAULT NULL,
  `moderated_commenting_enabled` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `complete_works` (`complete`,`posted`,`hidden_by_admin`),
  KEY `index_works_on_delta` (`delta`),
  KEY `index_works_on_imported_from_url` (`imported_from_url`),
  KEY `index_works_on_ip_address` (`ip_address`),
  KEY `index_works_on_language_id` (`language_id`),
  KEY `visible_works` (`restricted`,`posted`,`hidden_by_admin`),
  KEY `index_works_on_revised_at` (`revised_at`),
  KEY `index_works_on_spam` (`spam`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `wrangling_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `fandom_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `wrangling_assignments_by_fandom_id` (`fandom_id`),
  KEY `wrangling_assignments_by_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `wrangling_guidelines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `content_sanitizer_version` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20141003204623');

INSERT INTO schema_migrations (version) VALUES ('20141003205439');

INSERT INTO schema_migrations (version) VALUES ('20141004123421');

INSERT INTO schema_migrations (version) VALUES ('20141127004302');

INSERT INTO schema_migrations (version) VALUES ('20150725141326');

INSERT INTO schema_migrations (version) VALUES ('20150901024743');

INSERT INTO schema_migrations (version) VALUES ('20150901132832');