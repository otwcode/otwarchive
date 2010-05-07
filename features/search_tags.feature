@tags
Feature: Search Tags
  In order to figure out how to use cucumber with thinking sphinx
  As a humble coder
  I want to figure out how to test tag search

  Scenario: Search tags
    Given I have a Fandom tag named "first"
      And I have a canonical Character tag named "first last"
      And the Sphinx indexes are updated
    When I am on the tag search page
      And I fill in "tag_search" with "first"
      And I press "Search tags"
    Then I should see "3 Found"
      And I should see "first (0)"
      And I should see "Fandom: first fandom (0)"
      And I should see "Character: first last (0)"
    When I am on the tag search page
      And I fill in "tag_search" with "first"
      And I select "Fandom" from "type"
      And I press "Search tags"
    Then I should see "2 Found"
      And I should see "first (0)"
      And I should see "Fandom: first fandom (0)"
      And I should not see "first last (0)"
    When I am on the tag search page
      And I fill in "tag_search" with "first"
      And I check "canonical?"
      And I press "Search tags"
    Then I should see "1 Found"
      And I should see "first last (0)"
      And I should not see "first (0)"
      And I should not see "Fandom: first fandom (0)"
