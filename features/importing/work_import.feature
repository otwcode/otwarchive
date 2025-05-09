@import
Feature: Import Works
  In order to have an archive full of works
  As an author
  I want to create new works by importing them

  Scenario: You can't create a work unless you're logged in
  When I go to the import page
  Then I should see "Please log in"

  Scenario: Creating a new minimally valid work
    When I set up importing with a mock website
    Then I should see "Import New Work"
    When I fill in "urls" with "http://import-site-without-tags"
      And I press "Import"
    Then I should see "Language cannot be blank."
    When I select "Deutsch" from "Choose a language"
      And I press "Import"
    Then I should see "Preview"
      And I should see "Untitled Imported Work"
      And I should see "Language: Deutsch"
      And I should not see "A work has already been imported from http://import-site-without-tags"
      And I should see "No Fandom"
      And I should see "Chose Not To"
      And I should see "Not Rated"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I go to the works page
    Then I should see "Untitled Imported Work"

  Scenario: With override disabled and tag detection enabled, tags should be detected
    When I start importing "http://import-site-with-tags" with a mock website
      And I select "Deutsch" from "Choose a language"
      And I select "Explicit" from "Rating"
      And I check "No Archive Warnings Apply"
      And I fill in "Fandoms" with "Idol RPF"
      And I check "M/M"
      And I fill in "Relationships" with "Adam/Kris"
      And I fill in "Characters" with "Adam Lambert, Kris Allen"
      And I fill in "Additional Tags" with "kinkmeme"
      And I fill in "Notes at the beginning" with "This is a <i>note</i>"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Detected Title"
      And I should see "Language: Deutsch"
      And I should see "Explicit"
      And I should see "Archive Warning: Underage Sex"
      And I should see "Fandom: Detected Fandom"
      And I should see "Category: M/M"
      And I should see "Relationship: Detected 1/Detected 2"
      And I should see "Characters: Detected 1Detected 2"
      And I should see "Additional Tags: Detected tag 1Detected tag 2"
      And I should see "Notes: This is a content note."
    When I press "Post"
    Then I should see "Work was successfully posted."

  Scenario: With override and tag detection enabled, provided tags should be used when tags are entered
    When I start importing "http://import-site-with-tags" with a mock website
      And I select "Deutsch" from "Choose a language"
      And I check "override_tags"
      And I choose "detect_tags_true"
      And I select "Mature" from "Rating"
      And I check "No Archive Warnings Apply"
      And I fill in "Fandoms" with "Idol RPF"
      And I check "F/M"
      And I fill in "Relationships" with "Adam/Kris"
      And I fill in "Characters" with "Adam Lambert, Kris Allen"
      And I fill in "Additional Tags" with "kinkmeme"
      And I fill in "Notes at the beginning" with "This is a <i>note</i>"
    When I press "Import"
      Then I should see "Preview"
      And I should see "Detected Title"
      And I should see "Language: Deutsch"
      And I should see "Rating: Mature"
      And I should see "Archive Warning: No Archive Warnings"
      And I should see "Fandom: Idol RPF"
      And I should see "Category: F/M"
      And I should see "Relationship: Adam/Kris"
      And I should see "Characters: Adam LambertKris Allen"
      And I should see "Additional Tags: kinkmeme"
      And I should see "Notes: This is a note"
    When I press "Post"
    Then I should see "Work was successfully posted."

  Scenario: With override and tag detection enabled, both provided and detected tags should be used when not all tags are entered
    When I start importing "http://import-site-with-tags" with a mock website
      And I select "Deutsch" from "Choose a language"
      And I check "override_tags"
      And I choose "detect_tags_true"
      And I select "Mature" from "Rating"
      And I check "No Archive Warnings Apply"
      And I fill in "Characters" with "Adam Lambert, Kris Allen"
      And I fill in "Additional Tags" with "kinkmeme"
      And I fill in "Notes at the beginning" with "This is a <i>note</i>"
      And I press "Import"
    Then I should see "Preview"
      And I should see "Detected Title"
      And I should see "Language: Deutsch"
      And I should see "Rating: Mature"
      And I should see "Archive Warning: No Archive Warnings"
      And I should see "Fandom: Detected Fandom"
      And I should see "Relationship: Detected 1/Detected 2"
      And I should see "Characters: Adam LambertKris Allen"
      And I should see "Additional Tags: kinkmeme"
      And I should see "Notes: This is a note"
      And I should not see "Category: M/M"
    When I press "Post"
    Then I should see "Work was successfully posted."

  Scenario: Default tags should be used when no tags are entered, and override is enabled and tag detection is disabled
    When I start importing "http://import-site-with-tags" with a mock website
      And I check "override_tags"
      And I choose "detect_tags_false"
    When I press "Import"
    Then I should see "Detected Title"
      And I should see "Rating: Not Rated"
      And I should see "Archive Warning: Creator Chose Not To Use Archive Warnings"
      And I should see "Fandom: No Fandom"
      And I should not see "Relationship:"
      And I should not see "Additional Tags:"
      And I should not see "Relationship: Detected 1/Detected 2"

  Scenario Outline: Admins see IP address on imported works
    Given I import "http://import-site-with-tags" with a mock website
      And I press "Post"
    When I am logged in as a "<role>" admin
      And I go to the "Detected Title" work page
    Then I should see "IP Address: 127.0.0.1"

    Examples:
    | role             |
    | legal            |
    | policy_and_abuse |

  Scenario Outline: Admins see IP address on works imported without preview
    Given I start importing "http://import-site-with-tags" with a mock website
      And I check "Post without previewing"
      And I press "Import"
    When I am logged in as a "<role>" admin
      And I go to the "Detected Title" work page
    Then I should see "IP Address: 127.0.0.1"

    Examples:
    | role             |
    | legal            |
    | policy_and_abuse |

  Scenario Outline: Admins see IP address on multi-chapter works imported without preview
    Given I import the urls with mock websites as chapters without preview
      """
      http://import-site-without-tags
      http://second-import-site-without-tags
      """
    When I am logged in as a "policy_and_abuse" admin
      And I go to the "Untitled Imported Work" work page
    Then I should see "Chapters:2/2"
      And I should see "IP Address: 127.0.0.1"

    Examples:
    | role             |
    | legal            |
    | policy_and_abuse |

  Scenario: Imported works can be set to restricted
    When I start importing "http://import-site-with-tags" with a mock website
      And I check "Only show imported works to registered users"
      And I press "Import"
      And I press "Post"
    When I am logged out
      And I go to the "Detected Title" work page
    Then I should see "This work is only available to registered users of the Archive."

  Scenario: Imported works can have comments enabled to guests
    When I start importing "http://import-site-with-tags" with a mock website
      And I choose "comment_permissions_enable_all"
      And I press "Import"
      And I press "Post"
    When I am logged out
      And I go to the "Detected Title" work page
      And I follow "Yes, Continue"
    Then I should see "Guest name"

  Scenario: Imported works can have comments disabled to guests
    When I start importing "http://import-site-with-tags" with a mock website
      And I choose "comment_permissions_disable_anon"
      And I press "Import"
      And I press "Post"
    When I am logged out
      And I go to the "Detected Title" work page
      And I follow "Yes, Continue"
    Then I should see "Sorry, this work doesn't allow non-Archive users to comment."

  Scenario: Imported works can have comments disabled
    When I start importing "http://import-site-with-tags" with a mock website
      And I choose "comment_permissions_disable_all"
      And I press "Import"
      And I press "Post"
    When I go to the "Detected Title" work page
    Then I should see "Sorry, this work doesn't allow comments."

  Scenario: Imported works can have comment moderation off
    When I start importing "http://import-site-with-tags" with a mock website
      And I uncheck "moderated_commenting_enabled"
      And I press "Import"
      And I press "Post"
    When I am logged out
      And I go to the "Detected Title" work page
      And I follow "Yes, Continue"
    Then I should not see "This work's creator has chosen to moderate comments on the work."

  Scenario: Imported works can have comment moderation on
    When I start importing "http://import-site-with-tags" with a mock website
      And I choose "comment_permissions_enable_all"
      And I check "moderated_commenting_enabled"
      And I press "Import"
      And I press "Post"
    When I am logged out
      And I go to the "Detected Title" work page
      And I follow "Yes, Continue"
    Then I should see "This work's creator has chosen to moderate comments on the work."

  Scenario: Importing multiple works with backdating
    When I import the urls with mock websites
        """
        http://example.com/second-import-site-with-tags.html
        http://example.com/import-site-with-tags
        """
    Then I should see "Imported Works"
      And I should see "We were able to successfully upload"
      And I should see "Huddling"
      And I should see "Detected Title"
    When I follow "Huddling"
    Then I should see "Preview"
      And I should see "2010-01-11"

  Scenario: Importing a new multichapter work with backdating should have correct chapter index dates
    Given I set up importing with a mock website
    When I fill in "urls" with
        """
        http://example.com/import-site-with-tags
        http://example.com/second-import-site-with-tags.html
        """
      And I choose "Chapters in a single work"
      And I select "Deutsch" from "Choose a language"
      And I press "Import"
    Then I should see "Preview"
    When I press "Post"
    Then I should see "Language: Deutsch"
      And I should see "Published:2002-01-12"
      And I should see "Completed:2010-01-11"
    When I follow "Chapter Index"
    Then I should see "1. Chapter 1 (2002-01-12)"
      And I should see "2. Huddling (2010-01-11)"

  Scenario: Imported multichapter work should have the correct word count
    Given I import the urls with mock websites as chapters without preview
      """
      http://import-site-without-tags
      http://second-import-site-without-tags
      """
    Then I should see "Words:5"

  Scenario: Editing an imported multichapter work should have the correct word count
    Given I import the urls with mock websites as chapters without preview
      """
      http://import-site-without-tags
      http://second-import-site-without-tags
      """
    Then I should see "Words:5"
    When I follow "Edit"
      And I follow "1"
      And I fill in "content" with "some extra content that is longer than before"
      And I press "Post"
    Then I should see "Words:11"

#  Scenario: Import works for others and have them automatically notified

  @work_import_special_characters_auto_utf
  Scenario: Import a work with special characters (UTF-8, autodetect from page encoding)
    When I import "http://www.rbreu.de/otwtest/utf8_specified.html"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"

  @work_import_special_characters_auto_latin
  Scenario: Import a work with special characters (latin-1, autodetect from page encoding)
    When I import "http://www.rbreu.de/otwtest/latin1_specified.html"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"

  @work_import_special_characters_man_latin
  Scenario: Import a work with special characters (latin-1, must set manually)
    When I start importing "http://www.rbreu.de/otwtest/latin1_notspecified.html"
      And I select "ISO-8859-1" from "encoding"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"

  @work_import_special_characters_man_cp
  Scenario: Import a work with special characters (cp-1252, must set manually)
    When I start importing "http://rbreu.de/otwtest/cp1252.txt"
      And I select "Windows-1252" from "encoding"
    When I press "Import"
    Then I should see "Preview"
      And I should see "‘He hadn’t known.’"
      And I should see "So—what’s up?"
      And I should see "“Something witty.”"

  @work_import_special_characters_man_utf
  Scenario: Import a work with special characters (utf-8, must overwrite wrong page encoding)
    When I start importing "http://www.rbreu.de/otwtest/utf8_notspecified.html"
      And I select "UTF-8" from "encoding"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"

  # TODO: scarvesandcoffee.net is 403.
  @wip
  Scenario: Import a chaptered work from an efiction site
  When I import "http://www.scarvesandcoffee.net/viewstory.php?sid=9570"
  Then I should see "Preview"
    And I should see "Chapters: 4"
  When I press "Post"
    And I follow "Next Chapter →"
  Then I should see "Chapter 2"

  Scenario: Searching for an imported work by URL will redirect you to the work
    When I import "http://import-site-with-tags" with a mock website
      And I press "Post"
      And I go to the redirect page
      And I fill in "Original URL of work" with "http://import-site-with-tags"
      And I press "Go"
    Then I should see "Detected Title"

  Scenario: Import URLs as chapters of a single work and post from drafts page
    Given I import the urls with mock websites as chapters
      """
      http://import-site-without-tags
      http://second-import-site-without-tags
      """
    When I follow "My Dashboard"
      And I follow "Drafts ("
      And I follow "Post Draft"
    Then I should see "Your work was successfully posted."
      And I should not see "This chapter is a draft and hasn't been posted yet!"
    When I follow "Next Chapter"
    Then I should not see "This chapter is a draft and hasn't been posted yet!"

  Scenario: Importing as an archivist for an existing Archive author should send translated claim email
    Given a locale with translated emails
      And the following activated users exist
        | login    | email              |
        | sam      | sam@example.com    |
        | notsam   | notsam@example.com |
      And the user "sam" enables translated emails
      And all emails have been delivered
    When I import the mock work "http://import-site-without-tags" by "sam" with email "sam@example.com" and by "notsam" with email "notsam@example.com"
    Then I should see import confirmation
      And 1 email should be delivered to "sam@example.com"
      And the email should contain claim information
      And the email to "sam" should be translated
      And 1 email should be delivered to "notsam@example.com"
      And the email should contain claim information
      And the email to "notsam" should be non-translated
