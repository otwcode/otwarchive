@users @tag_wrangling @admin
Feature: Tag wrangling

  Scenario: Admin can rename a tag and it updates works and bookmarks.

    Given I am logged in as "audrey" with password "password"
      And I post the work "Renoir's Boating Party"
      And I bookmark the work "Renoir's Boating Party" with the tags "Amelie"
      And I post the work "Luncheon" with fandom "Amelie"
      # Visit the relevant pages to make sure the data gets cached.
      And I go to my bookmarks page
      And I go to my works page
      And I go to the work "Luncheon"
    When I am logged in as a "tag_wrangling" admin
      And I edit the tag "Amelie"
      And I fill in "Synonym of" with "Amélie"
      And I press "Save changes"
    Then I should see "Amélie is considered the same as Amelie by the database"
      And I should not see "Tag was successfully updated."
    When I fill in "Name" with "Amélie"
      And I press "Save changes"
    Then I should see "Tag was updated"
      And I should see "Amélie"
      And I should not see "Amelie"
    When I go to audrey's works page
    Then I should not see "Amelie"
      And I should see "Amélie"
    When I go to the work "Luncheon"
    Then I should not see "Amelie"
      And I should see "Amélie"
    When I go to audrey's bookmarks page
    Then I should not see "Amelie"
      And I should see "Amélie"

  Scenario: Admin can rename a tag using Eastern characters

  Given I am logged in as a "tag_wrangling" admin
    And a fandom exists with name: "先生", canonical: false
  When I edit the tag "先生"
    And I fill in "Name" with "てりやき"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should see "てりやき"
    And I should not see "先生"

  Scenario: Tag wrangler cannot rename a tag using Eastern characters

  Given I am logged in as a tag wrangler
    And a fandom exists with name: "先生", canonical: false
  When I edit the tag "先生"
    And I fill in "Name" with "てりやき"
    And I press "Save changes"
  Then I should not see "Tag was updated"
    And I should see "Only changes to capitalization and diacritic marks are permitted"

  Scenario: Admin can remove a user's wrangling privileges from the manage users page (this will leave assignments intact)

    Given the tag wrangler "tangler" with password "wr@ngl3r" is wrangler of "Testing"
    When I am logged in as a "tag_wrangling" admin
      And I am on the manage users page
    When I fill in "Name" with "tangler"
      And I press "Find"
    Then I should see "tangler" within "#admin_users_table"
    When I uncheck the "Tag Wrangler" role checkbox
      And I press "Update"
    Then I should see "User was successfully updated."
      And "tangler" should not be a tag wrangler
      And "Testing" should be assigned to the wrangler "tangler"

  Scenario: Admin can remove a user's wrangling assignments

    Given the tag wrangler "tangler" with password "wr@ngl3r" is wrangler of "Testing"
    When I am logged in as a "tag_wrangling" admin
      And I am on the wranglers page
      And I follow "x"
    Then I should see "Wranglers were successfully unassigned!"
      And "Testing" should not be assigned to the wrangler "tangler"
    When I edit the tag "Testing"
    Then I should see "Sign Up"

  Scenario: Tag wrangling admins can download a wrangler's wrangled tags report CSV

    Given the tag wrangler "tangler" with password "wr@ngl3r" is wrangler of "Testing"
      And I am logged in as a "tag_wrangling" admin
    When I go to the wrangling page for "tangler"
    Then I should see "Tags Wrangled (CSV)"
    When I follow "Tags Wrangled (CSV)"
    Then I should download a csv file with the header row "Name Last Updated Type Merger Fandoms Unwrangleable"
