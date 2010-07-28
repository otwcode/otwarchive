@wip @tags
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
   Then I should see "Tag was updated."
     And I should not see "We couldn't save this tag, sorry"
  When I follow "New Tag"
    And I fill in "Name" with "România"
    And I check "Canonical"
    And I choose "Freeform"
    And I press "Save changes"
  Then I should see "Tag was successfully created."
    But I should not see "România - Freeform"