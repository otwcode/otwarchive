@no-txn @tags @tag_wrangling @search
Feature: Search Tags
  In order to find tags
  As a user
  I want to use tag search

  Scenario: Search tags
    Given I have no tags
    And a fandom exists with name: "first fandom", canonical: false
    And a character exists with name: "first last", canonical: true
    And a relationship exists with name: "first last/someone else", canonical: false
    And the tag indexes are updated
    When I am on the search tags page
    And I fill in "tag_search" with "first"
    And I press "Search tags"
    Then I should see "3 Found"
    And I should see "Fandom: first fandom (0)"
    And I should not see "Fandom: first fandom (0)" within ".canonical"
    And I should see "Character: first last (0)" within ".canonical"
    And I should see "Relationship: first last/someone else (0)"
    When I am on the search tags page
    And I fill in "tag_search" with "first"
    And I select "Fandom" from "query[type]"
    And I press "Search tags"
    Then I should see "1 Found"
    And I should see "Fandom: first fandom (0)"
    And I should not see "first last"
    When I am on the search tags page
    And I fill in "tag_search" with "first"
    And I check "canonical"
    And I press "Search tags"
    Then I should see "1 Found"
    And I should see "first last (0)" within ".canonical"
    And I should not see "Fandom: first fandom (0)"
  # test search with slash
    When I am on the search tags page
    And I fill in "tag_search" with "first last\/someone else"
    And I press "Search tags"
    Then I should see "1 Found"
    And I should see "first last/someone else (0)"
