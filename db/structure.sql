
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `abuse_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `abuse_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ip_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comment_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `summary_sanitizer_version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `admin_activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_activities` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int DEFAULT NULL,
  `target_id` int DEFAULT NULL,
  `target_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `summary_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `admin_banners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_banners` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `content_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `banner_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `admin_blacklisted_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_blacklisted_emails` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_admin_blacklisted_emails_on_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `admin_post_taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_post_taggings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_post_tag_id` int DEFAULT NULL,
  `admin_post_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_post_taggings_on_admin_post_id` (`admin_post_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `admin_post_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_post_tags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `admin_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `content_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `translated_post_id` int DEFAULT NULL,
  `language_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_posts_on_created_at` (`created_at`),
  KEY `index_admin_posts_on_post_id` (`translated_post_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `admin_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `account_creation_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `invite_from_queue_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `invite_from_queue_number` bigint DEFAULT NULL,
  `invite_from_queue_frequency` mediumint DEFAULT NULL,
  `days_to_purge_unactivated` mediumint DEFAULT NULL,
  `last_updated_by` bigint DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `invite_from_queue_at` datetime DEFAULT '2009-11-07 21:27:21',
  `suspend_filter_counts` tinyint(1) DEFAULT '0',
  `suspend_filter_counts_at` datetime DEFAULT NULL,
  `enable_test_caching` tinyint(1) DEFAULT '0',
  `cache_expiration` bigint DEFAULT '10',
  `tag_wrangling_off` tinyint(1) NOT NULL DEFAULT '0',
  `default_skin_id` int DEFAULT NULL,
  `request_invite_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `creation_requires_invite` tinyint(1) NOT NULL DEFAULT '0',
  `downloads_enabled` tinyint(1) DEFAULT '1',
  `hide_spam` tinyint(1) NOT NULL DEFAULT '0',
  `disable_support_form` tinyint(1) NOT NULL DEFAULT '0',
  `disabled_support_form_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `disabled_support_form_text_sanitizer_version` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_admin_settings_on_last_updated_by` (`last_updated_by`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `login` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `encrypted_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `roles` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_keys` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `banned` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_api_keys_on_access_token` (`access_token`),
  UNIQUE KEY `index_api_keys_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `archive_faq_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `archive_faq_translations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `archive_faq_id` int DEFAULT NULL,
  `locale` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_archive_faq_translations_on_archive_faq_id` (`archive_faq_id`),
  KEY `index_archive_faq_translations_on_locale` (`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `archive_faqs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `archive_faqs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `position` int DEFAULT '1',
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_archive_faqs_on_slug` (`slug`),
  KEY `index_archive_faqs_on_position` (`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `audits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `auditable_id` int DEFAULT NULL,
  `auditable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `associated_id` int DEFAULT NULL,
  `associated_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `user_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `audited_changes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `version` int DEFAULT '0',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remote_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `request_uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `associated_index` (`associated_id`,`associated_type`),
  KEY `auditable_index` (`auditable_id`,`auditable_type`),
  KEY `index_audits_on_created_at` (`created_at`),
  KEY `index_audits_on_request_uuid` (`request_uuid`),
  KEY `user_index` (`user_id`,`user_type`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `bookmarks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookmarks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `bookmarkable_type` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `bookmarkable_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `bookmarker_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `private` tinyint(1) DEFAULT '0',
  `updated_at` datetime DEFAULT NULL,
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `pseud_id` int NOT NULL,
  `rec` tinyint(1) NOT NULL DEFAULT '0',
  `delta` tinyint(1) DEFAULT '1',
  `bookmarker_notes_sanitizer_version` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_bookmarkable_pseud` (`bookmarkable_id`,`bookmarkable_type`,`pseud_id`),
  KEY `index_bookmarks_on_private_and_hidden_by_admin_and_created_at` (`private`,`hidden_by_admin`,`created_at`),
  KEY `index_bookmarks_on_pseud_id` (`pseud_id`),
  KEY `fk_bookmarks_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `challenge_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `challenge_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `collection_id` int DEFAULT NULL,
  `creation_id` int DEFAULT NULL,
  `creation_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `offer_signup_id` int DEFAULT NULL,
  `request_signup_id` int DEFAULT NULL,
  `pinch_hitter_id` int DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `fulfilled_at` datetime DEFAULT NULL,
  `defaulted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pinch_request_signup_id` int DEFAULT NULL,
  `covered_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_challenge_assignments_on_collection_id` (`collection_id`),
  KEY `assignments_on_creation_id` (`creation_id`),
  KEY `assignments_on_creation_type` (`creation_type`),
  KEY `assignments_on_defaulted_at` (`defaulted_at`),
  KEY `assignments_on_offer_signup_id` (`offer_signup_id`),
  KEY `assignments_on_pinch_hitter_id` (`pinch_hitter_id`),
  KEY `assignments_on_offer_sent_at` (`sent_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `challenge_claims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `challenge_claims` (
  `id` int NOT NULL AUTO_INCREMENT,
  `collection_id` int DEFAULT NULL,
  `creation_id` int DEFAULT NULL,
  `creation_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_signup_id` int DEFAULT NULL,
  `request_prompt_id` int DEFAULT NULL,
  `claiming_user_id` int DEFAULT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `challenge_signups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `challenge_signups` (
  `id` int NOT NULL AUTO_INCREMENT,
  `collection_id` int DEFAULT NULL,
  `pseud_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `assigned_as_request` tinyint(1) DEFAULT '0',
  `assigned_as_offer` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_challenge_signups_on_collection_id` (`collection_id`),
  KEY `signups_on_pseud_id` (`pseud_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `chapters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chapters` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `position` int DEFAULT '1',
  `work_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `posted` tinyint(1) NOT NULL DEFAULT '0',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `word_count` int DEFAULT NULL,
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `published_at` date DEFAULT NULL,
  `endnotes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `content_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `notes_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `summary_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `endnotes_sanitizer_version` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_chapters_on_work_id` (`work_id`),
  KEY `works_chapter_index` (`work_id`)
) ENGINE=InnoDB AUTO_INCREMENT=173 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `collection_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `collection_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `collection_id` int DEFAULT NULL,
  `item_id` int DEFAULT NULL,
  `item_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Work',
  `user_approval_status` tinyint NOT NULL DEFAULT '0',
  `collection_approval_status` tinyint NOT NULL DEFAULT '0',
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
) ENGINE=InnoDB AUTO_INCREMENT=1018350796 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `collection_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `collection_participants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `collection_id` int DEFAULT NULL,
  `pseud_id` int DEFAULT NULL,
  `participant_role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'None',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `by collection and pseud` (`collection_id`,`pseud_id`),
  KEY `participants_by_collection_and_role` (`collection_id`,`participant_role`),
  KEY `participants_pseud_id` (`pseud_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1018350796 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `collection_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `collection_preferences` (
  `id` int NOT NULL AUTO_INCREMENT,
  `collection_id` int DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=1018350796 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `collection_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `collection_profiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `collection_id` int DEFAULT NULL,
  `intro` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `faq` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `rules` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `gift_notification` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `intro_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `faq_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `rules_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `assignment_notification` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_collection_profiles_on_collection_id` (`collection_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1018350796 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `collections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `header_image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `challenge_id` int DEFAULT NULL,
  `challenge_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon_file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon_content_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon_file_size` int DEFAULT NULL,
  `icon_updated_at` datetime DEFAULT NULL,
  `description_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `icon_alt_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `icon_comment_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `index_collections_on_name` (`name`),
  KEY `index_collections_on_parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pseud_id` int DEFAULT NULL,
  `comment_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `depth` int DEFAULT NULL,
  `threaded_left` int DEFAULT NULL,
  `threaded_right` int DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `commentable_id` int DEFAULT NULL,
  `commentable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `thread` int DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approved` tinyint(1) NOT NULL DEFAULT '0',
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `edited_at` datetime DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `parent_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comment_content_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `unreviewed` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_comments_commentable` (`commentable_id`,`commentable_type`),
  KEY `index_comments_on_ip_address` (`ip_address`),
  KEY `index_comments_parent` (`parent_id`,`parent_type`),
  KEY `index_comments_on_pseud_id` (`pseud_id`),
  KEY `comments_by_thread` (`thread`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `common_taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `common_taggings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `common_tag_id` int NOT NULL,
  `filterable_id` int NOT NULL,
  `filterable_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_common_tags` (`common_tag_id`,`filterable_type`,`filterable_id`),
  KEY `index_common_taggings_on_filterable_id` (`filterable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3000 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `creatorships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `creatorships` (
  `id` int NOT NULL AUTO_INCREMENT,
  `creation_id` int DEFAULT NULL,
  `creation_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pseud_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `approved` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `creation_id_creation_type_pseud_id` (`creation_id`,`creation_type`,`pseud_id`),
  KEY `index_creatorships_pseud` (`pseud_id`)
) ENGINE=InnoDB AUTO_INCREMENT=596033519 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `delayed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delayed_jobs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `priority` int DEFAULT '0',
  `attempts` int DEFAULT '0',
  `handler` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_error` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_failed_at` (`failed_at`),
  KEY `delayed_jobs_locked_at` (`locked_at`),
  KEY `delayed_jobs_locked_by` (`locked_by`),
  KEY `delayed_jobs_run_at` (`run_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `external_author_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `external_author_names` (
  `id` int NOT NULL AUTO_INCREMENT,
  `external_author_id` int NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_external_author_names_on_external_author_id` (`external_author_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `external_authors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `external_authors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_claimed` tinyint(1) NOT NULL DEFAULT '0',
  `user_id` int DEFAULT NULL,
  `do_not_email` tinyint(1) NOT NULL DEFAULT '0',
  `do_not_import` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_external_authors_on_email` (`email`),
  KEY `index_external_authors_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `external_creatorships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `external_creatorships` (
  `id` int NOT NULL AUTO_INCREMENT,
  `creation_id` int DEFAULT NULL,
  `creation_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `archivist_id` int DEFAULT NULL,
  `external_author_name_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_external_creatorships_on_archivist_id` (`archivist_id`),
  KEY `index_external_creatorships_on_creation_id_and_creation_type` (`creation_id`,`creation_type`),
  KEY `index_external_creatorships_on_external_author_name_id` (`external_author_name_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `external_works`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `external_works` (
  `id` int NOT NULL AUTO_INCREMENT,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `author` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `dead` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `summary_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `language_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `fannish_next_of_kins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fannish_next_of_kins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `kin_id` int DEFAULT NULL,
  `kin_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_fannish_next_of_kins_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `favorite_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorite_tags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `tag_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_favorite_tags_on_user_id_and_tag_id` (`user_id`,`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedbacks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comment_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `summary_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `ip_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rollout` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `filter_counts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `filter_counts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `filter_id` bigint NOT NULL,
  `public_works_count` bigint DEFAULT '0',
  `unhidden_works_count` bigint DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_filter_counts_on_filter_id` (`filter_id`),
  KEY `index_public_works_count` (`public_works_count`),
  KEY `index_unhidden_works_count` (`unhidden_works_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `filter_taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `filter_taggings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `filter_id` bigint NOT NULL,
  `filterable_id` bigint NOT NULL,
  `filterable_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `inherited` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_filter_taggings_filterable` (`filterable_id`,`filterable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=419 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gift_exchanges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gift_exchanges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `request_restriction_id` int DEFAULT NULL,
  `offer_restriction_id` int DEFAULT NULL,
  `requests_num_required` int NOT NULL DEFAULT '1',
  `offers_num_required` int NOT NULL DEFAULT '1',
  `requests_num_allowed` int NOT NULL DEFAULT '1',
  `offers_num_allowed` int NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `signup_instructions_general` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `signup_instructions_requests` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `signup_instructions_offers` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `signup_open` tinyint(1) NOT NULL DEFAULT '0',
  `signups_open_at` datetime DEFAULT NULL,
  `signups_close_at` datetime DEFAULT NULL,
  `assignments_due_at` datetime DEFAULT NULL,
  `works_reveal_at` datetime DEFAULT NULL,
  `authors_reveal_at` datetime DEFAULT NULL,
  `prompt_restriction_id` int DEFAULT NULL,
  `request_url_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_description_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `offer_url_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `offer_description_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `time_zone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `potential_match_settings_id` int DEFAULT NULL,
  `assignments_sent_at` datetime DEFAULT NULL,
  `signup_instructions_general_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `signup_instructions_requests_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `signup_instructions_offers_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `requests_summary_visible` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gifts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gifts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `work_id` int DEFAULT NULL,
  `recipient_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pseud_id` int DEFAULT NULL,
  `rejected` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_gifts_on_pseud_id` (`pseud_id`),
  KEY `index_gifts_on_recipient_name` (`recipient_name`),
  KEY `index_gifts_on_work_id` (`work_id`)
) ENGINE=InnoDB AUTO_INCREMENT=980190963 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `inbox_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inbox_comments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `feedback_comment_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `replied_to` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_inbox_comments_on_feedback_comment_id` (`feedback_comment_id`),
  KEY `index_inbox_comments_on_read_and_user_id` (`read`,`user_id`),
  KEY `index_inbox_comments_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `innodb_monitor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `innodb_monitor` (
  `a` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invitations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `creator_id` int DEFAULT NULL,
  `invitee_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `used` tinyint(1) NOT NULL DEFAULT '0',
  `invitee_id` int DEFAULT NULL,
  `invitee_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `creator_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `redeemed_at` datetime DEFAULT NULL,
  `from_queue` tinyint(1) NOT NULL DEFAULT '0',
  `external_author_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invitations_on_creator_id_and_creator_type` (`creator_id`,`creator_type`),
  KEY `index_invitations_on_external_author_id` (`external_author_id`),
  KEY `index_invitations_on_invitee_id_and_invitee_type` (`invitee_id`,`invitee_type`),
  KEY `index_invitations_on_token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `invite_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invite_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `simplified_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `ip_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_invite_requests_on_simplified_email` (`simplified_email`),
  KEY `index_invite_requests_on_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `known_issues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `known_issues` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `content_sanitizer_version` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `kudos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kudos` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `commentable_id` int DEFAULT NULL,
  `commentable_type` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ip_address` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_kudos_on_commentable_and_user` (`commentable_id`,`commentable_type`,`user_id`),
  UNIQUE KEY `index_kudos_on_commentable_and_ip_address` (`commentable_id`,`commentable_type`,`ip_address`),
  KEY `index_kudos_on_ip_address` (`ip_address`),
  KEY `index_kudos_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `languages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `short` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `support_available` tinyint(1) NOT NULL DEFAULT '0',
  `abuse_support_available` tinyint(1) NOT NULL DEFAULT '0',
  `sortable_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `index_languages_on_short` (`short`),
  KEY `index_languages_on_sortable_name` (`sortable_name`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `locales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locales` (
  `id` int NOT NULL AUTO_INCREMENT,
  `iso` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `short` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `main` tinyint(1) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `language_id` int NOT NULL,
  `interface_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `email_enabled` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_locales_on_iso` (`iso`),
  KEY `index_locales_on_language_id` (`language_id`),
  KEY `index_locales_on_short` (`short`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `log_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `admin_id` int DEFAULT NULL,
  `role_id` int DEFAULT NULL,
  `action` tinyint DEFAULT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `enddate` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `note_sanitizer_version` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_log_items_on_admin_id` (`admin_id`),
  KEY `index_log_items_on_role_id` (`role_id`),
  KEY `index_log_items_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `meta_taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `meta_taggings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `meta_tag_id` bigint NOT NULL,
  `sub_tag_id` bigint NOT NULL,
  `direct` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_meta_taggings_on_meta_tag_id_and_sub_tag_id` (`meta_tag_id`,`sub_tag_id`),
  KEY `index_meta_taggings_on_sub_tag_id` (`sub_tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `moderated_works`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `moderated_works` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `work_id` bigint NOT NULL,
  `approved` tinyint(1) NOT NULL DEFAULT '0',
  `reviewed` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_moderated_works_on_work_id` (`work_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `open_id_authentication_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `open_id_authentication_associations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `issued` int DEFAULT NULL,
  `lifetime` int DEFAULT NULL,
  `handle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assoc_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `server_url` blob,
  `secret` blob,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `open_id_authentication_nonces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `open_id_authentication_nonces` (
  `id` int NOT NULL AUTO_INCREMENT,
  `timestamp` int NOT NULL,
  `server_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `owned_set_taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `owned_set_taggings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owned_tag_set_id` int DEFAULT NULL,
  `set_taggable_id` int DEFAULT NULL,
  `set_taggable_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `owned_tag_sets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `owned_tag_sets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tag_set_id` int DEFAULT NULL,
  `visible` tinyint(1) NOT NULL DEFAULT '0',
  `nominated` tinyint(1) NOT NULL DEFAULT '0',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `featured` tinyint(1) NOT NULL DEFAULT '0',
  `description_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `fandom_nomination_limit` int NOT NULL DEFAULT '0',
  `character_nomination_limit` int NOT NULL DEFAULT '0',
  `relationship_nomination_limit` int NOT NULL DEFAULT '0',
  `freeform_nomination_limit` int NOT NULL DEFAULT '0',
  `usable` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `potential_match_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `potential_match_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `num_required_prompts` int NOT NULL DEFAULT '1',
  `num_required_fandoms` int NOT NULL DEFAULT '0',
  `num_required_characters` int NOT NULL DEFAULT '0',
  `num_required_relationships` int NOT NULL DEFAULT '0',
  `num_required_freeforms` int NOT NULL DEFAULT '0',
  `num_required_categories` int NOT NULL DEFAULT '0',
  `num_required_ratings` int NOT NULL DEFAULT '0',
  `num_required_archive_warnings` int NOT NULL DEFAULT '0',
  `include_optional_fandoms` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_characters` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_relationships` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_freeforms` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_categories` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_ratings` tinyint(1) NOT NULL DEFAULT '0',
  `include_optional_archive_warnings` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `potential_matches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `potential_matches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `collection_id` int DEFAULT NULL,
  `offer_signup_id` int DEFAULT NULL,
  `request_signup_id` int DEFAULT NULL,
  `num_prompts_matched` int DEFAULT NULL,
  `assigned` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `max_tags_matched` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_potential_matches_on_collection_id` (`collection_id`),
  KEY `index_potential_matches_on_offer_signup_id` (`offer_signup_id`),
  KEY `index_potential_matches_on_request_signup_id` (`request_signup_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `preferences` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
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
  `work_title_format` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'TITLE - AUTHOR - FANDOM',
  `hide_freeform` tinyint(1) NOT NULL DEFAULT '0',
  `first_login` tinyint(1) DEFAULT '1',
  `automatically_approve_collections` tinyint(1) NOT NULL DEFAULT '0',
  `collection_emails_off` tinyint(1) NOT NULL DEFAULT '0',
  `collection_inbox_off` tinyint(1) NOT NULL DEFAULT '0',
  `recipient_emails_off` tinyint(1) NOT NULL DEFAULT '0',
  `view_full_works` tinyint(1) NOT NULL DEFAULT '0',
  `time_zone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `plain_text_skin` tinyint(1) NOT NULL DEFAULT '0',
  `disable_work_skins` tinyint(1) NOT NULL DEFAULT '0',
  `skin_id` int DEFAULT NULL,
  `minimize_search_engines` tinyint(1) NOT NULL DEFAULT '0',
  `kudos_emails_off` tinyint(1) NOT NULL DEFAULT '0',
  `disable_share_links` tinyint(1) NOT NULL DEFAULT '0',
  `banner_seen` tinyint(1) NOT NULL DEFAULT '0',
  `preferred_locale` int NOT NULL DEFAULT '1',
  `allow_cocreator` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_preferences_on_skin_id` (`skin_id`),
  KEY `index_preferences_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=484751137 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `profiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `about_me` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `date_of_birth` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `about_me_sanitizer_version` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_profiles_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=765128317 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `prompt_memes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prompt_memes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `prompt_restriction_id` int DEFAULT NULL,
  `request_restriction_id` int DEFAULT NULL,
  `requests_num_required` int NOT NULL DEFAULT '1',
  `requests_num_allowed` int NOT NULL DEFAULT '5',
  `signup_open` tinyint(1) NOT NULL DEFAULT '1',
  `signups_open_at` datetime DEFAULT NULL,
  `signups_close_at` datetime DEFAULT NULL,
  `assignments_due_at` datetime DEFAULT NULL,
  `works_reveal_at` datetime DEFAULT NULL,
  `authors_reveal_at` datetime DEFAULT NULL,
  `signup_instructions_general` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `signup_instructions_requests` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `request_url_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_description_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `time_zone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signup_instructions_general_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `signup_instructions_requests_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `anonymous` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `prompt_restrictions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prompt_restrictions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tag_set_id` int DEFAULT NULL,
  `optional_tags_allowed` tinyint(1) NOT NULL DEFAULT '0',
  `description_allowed` tinyint(1) NOT NULL DEFAULT '1',
  `url_required` tinyint(1) NOT NULL DEFAULT '0',
  `fandom_num_required` int NOT NULL DEFAULT '0',
  `category_num_required` int NOT NULL DEFAULT '0',
  `rating_num_required` int NOT NULL DEFAULT '0',
  `character_num_required` int NOT NULL DEFAULT '0',
  `relationship_num_required` int NOT NULL DEFAULT '0',
  `freeform_num_required` int NOT NULL DEFAULT '0',
  `archive_warning_num_required` int NOT NULL DEFAULT '0',
  `fandom_num_allowed` int NOT NULL DEFAULT '1',
  `category_num_allowed` int NOT NULL DEFAULT '0',
  `rating_num_allowed` int NOT NULL DEFAULT '0',
  `character_num_allowed` int NOT NULL DEFAULT '1',
  `relationship_num_allowed` int NOT NULL DEFAULT '1',
  `freeform_num_allowed` int NOT NULL DEFAULT '0',
  `archive_warning_num_allowed` int NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `description_required` tinyint(1) NOT NULL DEFAULT '0',
  `url_allowed` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_fandom` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_character` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_rating` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_relationship` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_category` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_archive_warning` tinyint(1) NOT NULL DEFAULT '0',
  `allow_any_freeform` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_fandom` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_character` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_rating` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_relationship` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_category` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_archive_warning` tinyint(1) NOT NULL DEFAULT '0',
  `require_unique_freeform` tinyint(1) NOT NULL DEFAULT '0',
  `character_restrict_to_fandom` tinyint(1) NOT NULL DEFAULT '0',
  `relationship_restrict_to_fandom` tinyint(1) NOT NULL DEFAULT '0',
  `character_restrict_to_tag_set` tinyint(1) NOT NULL DEFAULT '0',
  `relationship_restrict_to_tag_set` tinyint(1) NOT NULL DEFAULT '0',
  `title_required` tinyint(1) NOT NULL DEFAULT '0',
  `title_allowed` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `prompts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prompts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `collection_id` int DEFAULT NULL,
  `challenge_signup_id` int DEFAULT NULL,
  `pseud_id` int DEFAULT NULL,
  `tag_set_id` int DEFAULT NULL,
  `optional_tag_set_id` int DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `position` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `any_fandom` tinyint(1) NOT NULL DEFAULT '0',
  `any_character` tinyint(1) NOT NULL DEFAULT '0',
  `any_rating` tinyint(1) NOT NULL DEFAULT '0',
  `any_relationship` tinyint(1) NOT NULL DEFAULT '0',
  `any_category` tinyint(1) NOT NULL DEFAULT '0',
  `any_archive_warning` tinyint(1) NOT NULL DEFAULT '0',
  `any_freeform` tinyint(1) NOT NULL DEFAULT '0',
  `anonymous` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_prompts_on_challenge_signup_id` (`challenge_signup_id`),
  KEY `index_prompts_on_collection_id` (`collection_id`),
  KEY `index_prompts_on_optional_tag_set_id` (`optional_tag_set_id`),
  KEY `index_prompts_on_tag_set_id` (`tag_set_id`),
  KEY `index_prompts_on_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `pseuds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pseuds` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `icon_file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon_content_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon_file_size` int DEFAULT NULL,
  `icon_updated_at` datetime DEFAULT NULL,
  `icon_alt_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `delta` tinyint(1) DEFAULT '1',
  `description_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `icon_comment_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `index_psueds_on_name` (`name`),
  KEY `index_pseuds_on_user_id_and_name` (`user_id`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `question_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_translations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `question_id` int DEFAULT NULL,
  `locale` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `question` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `content_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `screencast_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `is_translated` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_question_translations_on_locale` (`locale`),
  KEY `index_question_translations_on_question_id` (`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `archive_faq_id` int DEFAULT NULL,
  `question` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `anchor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `screencast` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `position` int DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_questions_on_archive_faq_id_and_position` (`archive_faq_id`,`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `readings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `readings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `major_version_read` int DEFAULT NULL,
  `minor_version_read` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `work_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_viewed` datetime DEFAULT NULL,
  `view_count` int DEFAULT '0',
  `toread` tinyint(1) NOT NULL DEFAULT '0',
  `toskip` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_readings_on_user_id` (`user_id`),
  KEY `index_readings_on_work_id` (`work_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `related_works`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `related_works` (
  `id` int NOT NULL AUTO_INCREMENT,
  `parent_id` int DEFAULT NULL,
  `parent_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `work_id` int DEFAULT NULL,
  `reciprocal` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `translation` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_related_works_on_parent_id_and_parent_type` (`parent_id`,`parent_type`),
  KEY `index_related_works_on_work_id` (`work_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `authorizable_type` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `authorizable_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_roles_on_authorizable_id_and_authorizable_type` (`authorizable_id`,`authorizable_type`),
  KEY `index_roles_on_authorizable_type` (`authorizable_type`),
  KEY `index_roles_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `roles_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles_users` (
  `user_id` int DEFAULT NULL,
  `role_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  KEY `index_roles_users_on_role_id_and_user_id` (`role_id`,`user_id`),
  KEY `index_roles_users_on_user_id_and_role_id` (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `searches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `searches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `options` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `serial_works`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `serial_works` (
  `id` int NOT NULL AUTO_INCREMENT,
  `series_id` int DEFAULT NULL,
  `work_id` int DEFAULT NULL,
  `position` int DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_serial_works_on_series_id` (`series_id`),
  KEY `index_serial_works_on_work_id` (`work_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `series`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `series` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `series_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `restricted` tinyint(1) NOT NULL DEFAULT '1',
  `complete` tinyint(1) NOT NULL DEFAULT '0',
  `summary_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `series_notes_sanitizer_version` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `set_taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `set_taggings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tag_id` int DEFAULT NULL,
  `tag_set_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_set_taggings_on_tag_id` (`tag_id`),
  KEY `index_set_taggings_on_tag_set_id` (`tag_set_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `skin_parents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `skin_parents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `child_skin_id` int DEFAULT NULL,
  `parent_skin_id` int DEFAULT NULL,
  `position` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `skins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `skins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `author_id` int DEFAULT NULL,
  `css` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `public` tinyint(1) DEFAULT '0',
  `official` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `icon_file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon_content_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon_file_size` int DEFAULT NULL,
  `icon_updated_at` datetime DEFAULT NULL,
  `icon_alt_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `margin` int DEFAULT NULL,
  `paragraph_gap` int DEFAULT NULL,
  `font` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `base_em` int DEFAULT NULL,
  `background_color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `foreground_color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `rejected` tinyint(1) NOT NULL DEFAULT '0',
  `admin_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paragraph_margin` float DEFAULT NULL,
  `headercolor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `accent_color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `media` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ie_condition` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `filename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `stat_counters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stat_counters` (
  `id` int NOT NULL AUTO_INCREMENT,
  `work_id` int DEFAULT NULL,
  `hit_count` int NOT NULL DEFAULT '0',
  `download_count` int NOT NULL DEFAULT '0',
  `comments_count` int NOT NULL DEFAULT '0',
  `kudos_count` int NOT NULL DEFAULT '0',
  `bookmarks_count` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_hit_counters_on_work_id` (`work_id`),
  KEY `index_hit_counters_on_hit_count` (`hit_count`)
) ENGINE=InnoDB AUTO_INCREMENT=1043096534 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscriptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `subscribable_id` int DEFAULT NULL,
  `subscribable_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subscribable` (`subscribable_id`,`subscribable_type`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tag_nominations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tag_nominations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tag_set_nomination_id` int DEFAULT NULL,
  `fandom_nomination_id` int DEFAULT NULL,
  `tagname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `parent_tagname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approved` tinyint(1) NOT NULL DEFAULT '0',
  `rejected` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `canonical` tinyint(1) NOT NULL DEFAULT '0',
  `exists` tinyint(1) NOT NULL DEFAULT '0',
  `parented` tinyint(1) NOT NULL DEFAULT '0',
  `synonym` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tag_nominations_on_tagname` (`tagname`),
  KEY `index_tag_nominations_on_type_and_fandom_nomination_id` (`type`,`fandom_nomination_id`),
  KEY `index_tag_nominations_on_type_and_synonym` (`type`,`synonym`),
  KEY `index_tag_nominations_on_type_and_tag_set_nomination_id` (`type`,`tag_set_nomination_id`),
  KEY `index_tag_nominations_on_type_and_tagname` (`type`,`tagname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tag_set_associations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tag_set_associations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owned_tag_set_id` int DEFAULT NULL,
  `tag_id` int DEFAULT NULL,
  `parent_tag_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tag_set_nominations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tag_set_nominations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pseud_id` int DEFAULT NULL,
  `owned_tag_set_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tag_set_ownerships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tag_set_ownerships` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pseud_id` int DEFAULT NULL,
  `owned_tag_set_id` int DEFAULT NULL,
  `owner` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tag_sets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tag_sets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `taggings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tagger_id` int DEFAULT NULL,
  `taggable_id` int NOT NULL,
  `taggable_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `tagger_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_taggings_polymorphic` (`tagger_id`,`tagger_type`,`taggable_id`,`taggable_type`),
  KEY `index_taggings_taggable` (`taggable_id`,`taggable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=1067725751 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '',
  `canonical` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `taggings_count_cache` int DEFAULT '0',
  `adult` tinyint(1) DEFAULT '0',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `merger_id` int DEFAULT NULL,
  `delta` tinyint(1) DEFAULT '0',
  `last_wrangler_id` int DEFAULT NULL,
  `last_wrangler_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unwrangleable` tinyint(1) NOT NULL DEFAULT '0',
  `sortable_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tags_on_name` (`name`),
  KEY `index_tags_on_canonical` (`canonical`),
  KEY `tag_created_at_index` (`created_at`),
  KEY `index_tags_on_id_and_type` (`id`,`type`),
  KEY `index_tags_on_merger_id` (`merger_id`),
  KEY `index_tags_on_sortable_name` (`sortable_name`),
  KEY `index_tags_on_taggings_count_cache` (`taggings_count_cache`),
  KEY `index_tags_on_type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=1063754168 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_invite_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_invite_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `granted` tinyint(1) NOT NULL DEFAULT '0',
  `handled` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_invite_requests_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confirmation_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `login` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `encrypted_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `suspended` tinyint(1) NOT NULL DEFAULT '0',
  `banned` tinyint(1) NOT NULL DEFAULT '0',
  `invitation_id` int DEFAULT NULL,
  `suspended_until` datetime DEFAULT NULL,
  `out_of_invites` tinyint(1) NOT NULL DEFAULT '1',
  `failed_attempts` int DEFAULT '0',
  `accepted_tos_version` int DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `reset_password_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unlock_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `recently_reset` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_login` (`login`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_unlock_token` (`unlock_token`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `work_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `work_links` (
  `id` int NOT NULL AUTO_INCREMENT,
  `work_id` int DEFAULT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `count` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `work_links_work_id_url` (`work_id`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `works`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `works` (
  `id` int NOT NULL AUTO_INCREMENT,
  `expected_number_of_chapters` int DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `major_version` int DEFAULT '1',
  `minor_version` int DEFAULT '0',
  `posted` tinyint(1) NOT NULL DEFAULT '0',
  `language_id` int DEFAULT NULL,
  `restricted` tinyint(1) NOT NULL DEFAULT '0',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `word_count` int DEFAULT NULL,
  `hidden_by_admin` tinyint(1) NOT NULL DEFAULT '0',
  `delta` tinyint(1) DEFAULT '0',
  `revised_at` datetime DEFAULT NULL,
  `title_to_sort_on` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `backdate` tinyint(1) NOT NULL DEFAULT '0',
  `endnotes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `imported_from_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `complete` tinyint(1) NOT NULL DEFAULT '0',
  `summary_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `notes_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `endnotes_sanitizer_version` smallint NOT NULL DEFAULT '0',
  `work_skin_id` int DEFAULT NULL,
  `in_anon_collection` tinyint(1) NOT NULL DEFAULT '0',
  `in_unrevealed_collection` tinyint(1) NOT NULL DEFAULT '0',
  `anon_commenting_disabled` tinyint(1) NOT NULL DEFAULT '0',
  `ip_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `wrangling_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wrangling_assignments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `fandom_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `wrangling_assignments_by_fandom_id` (`fandom_id`),
  KEY `wrangling_assignments_by_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `wrangling_guidelines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wrangling_guidelines` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `position` int DEFAULT NULL,
  `content_sanitizer_version` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

INSERT INTO `schema_migrations` (version) VALUES
('20141003204623'),
('20141003205439'),
('20141004123421'),
('20141127004302'),
('20150725141326'),
('20150901024743'),
('20150901132832'),
('20151018165632'),
('20151129234505'),
('20160331005706'),
('20160416163754'),
('20160706031054'),
('20170321202522'),
('20170322092920'),
('20170331170222'),
('20170414154143'),
('20170615090455'),
('20170918172719'),
('20170919143944'),
('20171006090901'),
('20171030201300'),
('20171030220348'),
('20171031204025'),
('20171114212142'),
('20180108220405'),
('20180428201347'),
('20180519055830'),
('20180712000145'),
('20180731034724'),
('20180811160316'),
('20180822202259'),
('20180901171307'),
('20180909203857'),
('20180917212655'),
('20181017032400'),
('20181113063726'),
('20181201022717'),
('20181222022628'),
('20181222042042'),
('20181224173813'),
('20190207034230'),
('20190213230717'),
('20190213231821'),
('20190214054439'),
('20190323185300'),
('20190405191806'),
('20190421213603'),
('20190423215601'),
('20190611212339'),
('20200115232918'),
('20200210013551'),
('20200221045607'),
('20200325021219'),
('20200406185632'),
('20200406190444'),
('20200412142208'),
('20200415010506'),
('20200423205608'),
('20200504132624');


