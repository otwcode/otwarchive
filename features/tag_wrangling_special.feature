@tags @tag_wrangling
Feature: Tag Wrangling - special cases

Scenario: Create a new tag that differs from an existing tag by accents or other markers
  Given the following activated tag wrangler exists
    | login          | password    |
    | wranglerette   | something   |
    And I am logged in as "wranglerette" with password "something"
    And a fandom exists with name: "Amelie", canonical: false
    And a character exists with name: "Romania", canonical: true
  When I edit the tag "Amelie"
    And I fill in "Synonym of" with "Amélie"
    And I press "Save changes"
  Then I should see "Amélie is considered the same as Amelie by the database"
    And I should not see "Tag was successfully updated."
  When I fill in "Name" with "Amélie"
    And I press "Save changes"
  Then I should see "Name can only be changed by an admin."
  When I follow "New Tag"
    And I fill in "Name" with "România"
    And I check "Canonical"
    And I choose "Freeform"
    And I press "Create Tag"
  Then I should see "Tag was successfully created."
    But I should see "România - Freeform"

  Scenario: Tags with non-standard characters in them - question mark and period
  
  Given basic tags
    And the following activated tag wrangler exists
      | login           | password   |
      | workauthor      | password   |
    And a character exists with name: "Evan ?", canonical: true
    And a character exists with name: "James T. Kirk", canonical: true
  When I am logged in as "workauthor" with password "password"
  When I post the work "Epic sci-fi"
    And I follow "Edit"
    And I fill in "Characters" with "Evan ?, James T. Kirk"
    And I press "Preview"
    And I press "Update"
  Then I should see "Work was successfully updated"
  When I view the tag "Evan ?"
    And I follow "filter works"
  Then I should see "1 Work found in Evan ?"
  When I view the tag "James T. Kirk"
    And I follow "filter works"
  Then I should see "1 Work found in James T. Kirk"
  
