@tags @tag_wrangling
Feature: Tag Wrangling - special cases

  Scenario: Works should be updated when accents are changed
    See AO3-4230 for a bug with the caching of this
    These require commits to work and therefore dirty the db

  When I am logged in as "wranglerette"
    And I edit the tag "Amelie"
    And I fill in "Name" with "Amélie"
    And I press "Save changes"
  Then I should see "Tag was updated"
  When I view the work "wrong"
  Then I should see "Amélie"
    And I should not see "Amelie"
  When I am on the works page
  Then I should see "Amélie"
    And I should not see "Amelie"
