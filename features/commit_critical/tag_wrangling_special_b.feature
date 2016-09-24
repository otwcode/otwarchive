@tags @tag_wrangling
Feature: Tag Wrangling - special cases

  Scenario: Works should be updated when capitalisation is changed
    See AO3-4230 for a bug with the caching of this
    These require commits to work and therefore dirty the db
  
  Given the following activated tag wrangler exists
    | login          |
    | wranglerette   |
    And a fandom exists with name: "amelie", canonical: false
    And I am logged in as "author"
    And I post the work "wrong" with fandom "amelie"
  When I am logged in as "wranglerette"
    And I edit the tag "amelie"
    And I fill in "Name" with "Amelie"
    And I press "Save changes"
  Then I should see "Tag was updated"
  When I view the work "wrong"
  Then I should see "Amelie"
    And I should not see "amelie"
  When I am on the works page
  Then I should see "Amelie"
    And I should not see "amelie"

  Scenario: Works should be updated when capitalisation is changed
    See AO3-4230 for a bug with the caching of this

  When I am logged in as "wranglerette"
    And I edit the tag "amelie"
    And I fill in "Name" with "Amelie"
    And I press "Save changes"
  Then I should see "Tag was updated"
  When I view the work "wrong"
  Then I should see "Amelie"
    And I should not see "amelie"
  When I am on the works page
  Then I should see "Amelie"
    And I should not see "amelie"
