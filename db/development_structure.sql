CREATE TABLE `admins` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `email` varchar(255) default NULL,
  `login` varchar(255) default NULL,
  `crypted_password` varchar(255) default NULL,
  `salt` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `bookmarks` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(50) default '',
  `created_at` datetime NOT NULL,
  `bookmarkable_type` varchar(15) NOT NULL default '',
  `bookmarkable_id` int(11) NOT NULL default '0',
  `user_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `fk_bookmarks_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `chapters` (
  `id` int(11) NOT NULL auto_increment,
  `content` text,
  `position` int(11) default '1',
  `work_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `pseud_id` int(11) default NULL,
  `content` text,
  `depth` int(11) default NULL,
  `threaded_left` int(11) default NULL,
  `threaded_right` int(11) default NULL,
  `is_deleted` tinyint(1) default NULL,
  `name` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `ip_address` varchar(255) default NULL,
  `commentable_id` int(11) default NULL,
  `commentable_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `thread` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `creatorships` (
  `id` int(11) NOT NULL auto_increment,
  `creation_id` int(11) default NULL,
  `creation_type` varchar(255) default NULL,
  `pseud_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `globalize_countries` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(2) default NULL,
  `english_name` varchar(255) default NULL,
  `date_format` varchar(255) default NULL,
  `currency_format` varchar(255) default NULL,
  `currency_code` varchar(3) default NULL,
  `thousands_sep` varchar(2) default NULL,
  `decimal_sep` varchar(2) default NULL,
  `currency_decimal_sep` varchar(2) default NULL,
  `number_grouping_scheme` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_globalize_countries_on_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `globalize_languages` (
  `id` int(11) NOT NULL auto_increment,
  `iso_639_1` varchar(2) default NULL,
  `iso_639_2` varchar(3) default NULL,
  `iso_639_3` varchar(3) default NULL,
  `rfc_3066` varchar(255) default NULL,
  `english_name` varchar(255) default NULL,
  `english_name_locale` varchar(255) default NULL,
  `english_name_modifier` varchar(255) default NULL,
  `native_name` varchar(255) default NULL,
  `native_name_locale` varchar(255) default NULL,
  `native_name_modifier` varchar(255) default NULL,
  `macro_language` tinyint(1) default NULL,
  `direction` varchar(255) default NULL,
  `pluralization` varchar(255) default NULL,
  `scope` varchar(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_globalize_languages_on_iso_639_1` (`iso_639_1`),
  KEY `index_globalize_languages_on_iso_639_2` (`iso_639_2`),
  KEY `index_globalize_languages_on_iso_639_3` (`iso_639_3`),
  KEY `index_globalize_languages_on_rfc_3066` (`rfc_3066`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `globalize_translations` (
  `id` int(11) NOT NULL auto_increment,
  `type` varchar(255) default NULL,
  `tr_key` varchar(255) default NULL,
  `table_name` varchar(255) default NULL,
  `item_id` int(11) default NULL,
  `facet` varchar(255) default NULL,
  `built_in` tinyint(1) default NULL,
  `language_id` int(11) default NULL,
  `pluralization_index` int(11) default NULL,
  `text` text,
  `namespace` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_globalize_translations_on_tr_key_and_language_id` (`tr_key`,`language_id`),
  KEY `globalize_translations_table_name_and_item_and_language` (`table_name`,`item_id`,`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `metadatas` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `summary` text,
  `notes` text,
  `described_id` int(11) default NULL,
  `described_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `open_id_authentication_associations` (
  `id` int(11) NOT NULL auto_increment,
  `issued` int(11) default NULL,
  `lifetime` int(11) default NULL,
  `handle` varchar(255) default NULL,
  `assoc_type` varchar(255) default NULL,
  `server_url` blob,
  `secret` blob,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `open_id_authentication_nonces` (
  `id` int(11) NOT NULL auto_increment,
  `timestamp` int(11) NOT NULL,
  `server_url` varchar(255) default NULL,
  `salt` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `pseuds` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `description` text,
  `is_default` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `roles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(40) default NULL,
  `authorizable_type` varchar(40) default NULL,
  `authorizable_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `roles_users` (
  `user_id` int(11) default NULL,
  `role_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `remember_token` varchar(255) default NULL,
  `email` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `activation_code` varchar(255) default NULL,
  `login` varchar(255) default NULL,
  `activated_at` datetime default NULL,
  `crypted_password` varchar(255) default NULL,
  `salt` varchar(255) default NULL,
  `identity_url` varchar(255) default NULL,
  `translation_mode_active` tinyint(1) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `works` (
  `id` int(11) NOT NULL auto_increment,
  `expected_number_of_chapters` int(11) default NULL,
  `is_complete` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `major_version` int(11) default NULL,
  `minor_version` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `schema_info` (version) VALUES (25)