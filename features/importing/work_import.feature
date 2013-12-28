@works
Feature: Import Works
  In order to have an archive full of works
  As an author
  I want to create new works by importing them

  Scenario: You can't create a work unless you're logged in
  When I go to the import page
  Then I should see "Please log in"

  @work_import_minimal_valid
  Scenario: Creating a new minimally valid work
    Given basic tags
      And I am logged in as a random user
    When I go to the import page
    Then I should see "Import New Work"
      And I fill in "urls" with "http://cesy.dreamwidth.org"
    When I press "Import"
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

  @work_import_tags
  Scenario: Creating a new work with tags
    Given basic tags
      And I am logged in as a random user
    When I go to the import page
    Then I should see "Import New Work"
      And I fill in "urls" with "http://astolat.dreamwidth.org/220479.html"
      And I select "Explicit" from "Rating"
      And I check "No Archive Warnings Apply"
      And I fill in "Fandoms" with "Idol RPF"
      And I check "M/M"
      And I fill in "Relationships" with "Adam/Kris"
      And I fill in "Characters" with "Adam Lambert, Kris Allen"
      And I fill in "Additional Tags" with "kinkmeme"
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
    When I press "Post"
    Then I should see "Work was successfully posted."

  @work_import_multi_tags_backdate
  Scenario: Importing multiple works with backdating
    Given basic tags
      And I am logged in as a random user
    When I go to the import page
    Then I should see "Import New Work"
      And I fill in "urls" with
        """
        http://www.intimations.org/fanfic/idol/Huddling.html
        http://www.intimations.org/fanfic/idol/Stardust.html
        """
    When I press "Import"
    Then I should see "Imported Works"
      And I should see "We were able to successfully upload"
      And I should see "Huddling"
      And I should see "Stardust"
    When I follow "Huddling"
    Then I should see "Preview"
      And I should see "2010-01-11"


#  Scenario: Import works for others and have them automatically notified

  @work_import_special_characters_auto_utf
  Scenario: Import a work with special characters (UTF-8, autodetect from page encoding)
    Given basic tags
      And I am logged in as a random user
    When I go to the import page
      And I fill in "urls" with "http://www.rbreu.de/otwtest/utf8_specified.html"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"
  @work_import_special_characters_auto_latin
  Scenario: Import a work with special characters (latin-1, autodetect from page encoding)
    Given basic tags
      And I am logged in as a random user
    When I go to the import page
      And I fill in "urls" with "http://www.rbreu.de/otwtest/latin1_specified.html"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"

  @work_import_special_characters_man_latin
  Scenario: Import a work with special characters (latin-1, must set manually)
    Given basic tags
      And I am logged in as a random user
    When I go to the import page
      And I fill in "urls" with "http://www.rbreu.de/otwtest/latin1_notspecified.html"
      And I select "ISO-8859-1" from "encoding"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"

  @work_import_special_characters_man_cp
  Scenario: Import a work with special characters (cp-1252, must set manually)
    Given basic tags
      And I am logged in as a random user
    When I go to the import page
      And I fill in "urls" with "http://rbreu.de/otwtest/cp1252.txt"
      And I select "Windows-1252" from "encoding"
    When I press "Import"
    Then I should see "Preview"
      And I should see "‘He hadn’t known.’"
      And I should see "So—what’s up?"
      And I should see "“Something witty.”"

  @work_import_special_characters_man_utf
  Scenario: Import a work with special characters (utf-8, must overwrite wrong page encoding)
    Given basic tags
      And I am logged in as a random user
    When I go to the import page
      And I fill in "urls" with "http://www.rbreu.de/otwtest/utf8_notspecified.html"
      And I select "UTF-8" from "encoding"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Das Maß aller Dinge" within "h2.title"
      And I should see "Ä Ö Ü é è È É ü ö ä ß ñ"

  @work_import_nul_character
  Scenario: Import a work with the illegal 00 character (string terminator)
    Given basic tags
      And I am logged in as a random user
    When I go to the import page
      And I fill in "urls" with "http://www.the-archive.net/viewstory.php?sid=1910"
    When I press "Import"
    Then I should see "Preview"
      And I should see "When I get out of here"
