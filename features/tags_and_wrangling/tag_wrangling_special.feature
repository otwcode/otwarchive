@tags @tag_wrangling
Feature: Tag Wrangling - special cases

  Scenario: Create a new tag that differs from an existing tag by accents or other markers

  Given the following activated tag wrangler exists
    | login          |
    | wranglerette   |
    And I am logged in as "wranglerette"
    And a fandom exists with name: "Amelie", canonical: false
    And a character exists with name: "Romania", canonical: true
  When I edit the tag "Amelie"
    And I fill in "Synonym of" with "Amélie"
    And I press "Save changes"
  Then I should see "Amélie is considered the same as Amelie by the database"
    And I should not see "Tag was successfully updated."
  When I fill in "Name" with "Amélie"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should see "Amélie"
    And I should not see "Amelie"
  When I follow "New Tag"
    And I fill in "Name" with "România"
    And I check "Canonical"
    And I choose "Freeform"
    And I press "Create Tag"
  Then I should see "Tag was successfully created."
    But I should see "România - Freeform"

  Scenario: Create a new tag that differs by more than just accents - user cannot change name

  Given the following activated tag wrangler exists
    | login          |
    | wranglerette   |
    And I am logged in as "wranglerette"
    And a fandom exists with name: "Amelie", canonical: false
  When I edit the tag "Amelie"
  When I fill in "Name" with "Amelia"
    And I press "Save changes"
  Then I should see "Name can only be changed by an admin."

  Scenario: Change capitalisation of a tag

  Given the following activated tag wrangler exists
    | login          |
    | wranglerette   |
    And I am logged in as "wranglerette"
    And a fandom exists with name: "amelie", canonical: false
  When I edit the tag "amelie"
    And I fill in "Synonym of" with "Amelie"
    And I press "Save changes"
  Then I should see "Amelie is considered the same as amelie by the database"
    And I should not see "Tag was successfully updated."
  When I fill in "Name" with "Amelie"
    And I press "Save changes"
  Then I should see "Tag was updated"

  Scenario: Tags with non-standard characters in them - question mark and period
  
  Given basic tags
    And the following activated tag wrangler exists
      | login           |
      | workauthor      |
    And a character exists with name: "Evan ?", canonical: true
    And a character exists with name: "James T. Kirk", canonical: true
  When I am logged in as "workauthor"
  When I post the work "Epic sci-fi"
    And I follow "Edit"
    And I fill in "Characters" with "Evan ?, James T. Kirk"
    And I press "Preview"
    And I press "Update"
  Then I should see "Work was successfully updated"
    And all search indexes are updated
  When I view the tag "Evan ?"
    And I follow "filter works"
  Then I should see "1 Work in Evan ?"
  When I view the tag "James T. Kirk"
    And I follow "filter works"
  Then I should see "1 Work in James T. Kirk"
  
