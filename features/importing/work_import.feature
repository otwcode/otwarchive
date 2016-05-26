@works
Feature: Import Works
  In order to have an archive full of works
  As an author
  I want to create new works by importing them

  Scenario: You can't create a work unless you're logged in
  When I go to the import page
  Then I should see "Please log in"

  Scenario: Creating a new minimally valid work
    When I set up importing
    Then I should see "Import New Work"
    When I fill in "urls" with "http://cesy.dreamwidth.org"
      And I press "Import"
    Then I should see "Preview"
      And I should see "Welcome"
      And I should not see "A work has already been imported from http://cesy.dreamwidth.org"
      And I should see "No Fandom"
      And I should see "Chose Not To"
      And I should see "Not Rated"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I go to the works page
    Then I should see "Recent Entries"

  Scenario: Creating a new work with tags
    When I start importing "http://astolat.dreamwidth.org/220479.html"
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
      And I should see "Extra Credit"
      And I should see "Explicit"
      And I should see "No Archive Warnings Apply"
      And I should see "Idol RPF"
      And I should see "M/M"
      And I should see "Adam/Kris"
      And I should see "Adam Lambert"
      And I should see "Kris Allen"
      And I should see "kinkmeme"
      And I should see "This is a note"
    When I press "Post"
    Then I should see "Work was successfully posted."

  Scenario: Importing multiple works with backdating
    When I import the urls
        """
        http://www.intimations.org/fanfic/idol/Huddling.html
        http://www.intimations.org/fanfic/idol/Stardust.html
        """
    Then I should see "Imported Works"
      And I should see "We were able to successfully upload"
      And I should see "Huddling"
      And I should see "Stardust"
    When I follow "Huddling"
    Then I should see "Preview"
      And I should see "2010-01-11"

  Scenario: Importing a new multichapter work with backdating should have correct chapter index dates
    Given basic tags
    And the following activated user exists
      | login          | password    |
      | cosomeone      | something   |
    And I am logged in as "cosomeone" with password "something"
    And I set my time zone to "UTC"
    When I go to the import page
    And I fill in "urls" with
         """
         http://rebecca2525.dreamwidth.org/3506.html
         http://rebecca2525.dreamwidth.org/4024.html
         """
    And I choose "import_multiple_chapters"
    When I press "Import"
      Then I should see "Preview"
    When I press "Post"
      Then I should see "Published:2000-01-10"
      Then I should see "Completed:2000-01-22"
    When I follow "Chapter Index"
      Then I should see "1. Chapter 1 (2000-01-10)"
      Then I should see "2. Importing Test Part 2 (2000-01-22)"

#  Scenario: Import works for others and have them automatically notified

  @work_import_special_characters_auto_utf
  Scenario: Import a work with special characters (UTF-8, autodetect from page encoding)
    When I import "http://www.rbreu.de/otwtest/utf8_specified.html"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"

  Scenario: Import a work with special characters (latin-1, autodetect from page encoding)
    When I import "http://www.rbreu.de/otwtest/latin1_specified.html"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"

  Scenario: Import a work with special characters (latin-1, must set manually)
    When I start importing "http://www.rbreu.de/otwtest/latin1_notspecified.html"
      And I select "ISO-8859-1" from "encoding"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"

  Scenario: Import a work with special characters (cp-1252, must set manually)
    When I start importing "http://rbreu.de/otwtest/cp1252.txt"
      And I select "Windows-1252" from "encoding"
    When I press "Import"
    Then I should see "Preview"
      And I should see "‘He hadn’t known.’"
      And I should see "So—what’s up?"
      And I should see "“Something witty.”"

  Scenario: Import a work with special characters (utf-8, must overwrite wrong page encoding)
    When I start importing "http://www.rbreu.de/otwtest/utf8_notspecified.html"
      And I select "UTF-8" from "encoding"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"

  Scenario: Import a chaptered work from an efiction site
  When I import "http://www.scarvesandcoffee.net/viewstory.php?sid=9570"
  Then I should see "Preview"
    And I should see "Chapters: 4"
  When I press "Post"
    And I follow "Next Chapter →"
  Then I should see "Chapter 2"

  Scenario: Imported works should be English language by default
    When I import "http://www.intimations.org/fanfic/idol/Huddling.html"
    Then I should see "Preview"
      And I should see "English"
