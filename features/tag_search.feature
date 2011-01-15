@no-txn @tags @tag_wrangling @search
Feature: Search Tags
  In order to figure out how to use cucumber with thinking sphinx
  As a humble coder
  I want to figure out how to test tag search

  Scenario: Search tags
    Given I have no tags
      And a fandom exists with name: "first fandom"
      And a character exists with name: "first last", canonical: true
      And the tag indexes are updated
    When I am on the search tags page
      And I fill in "tag_search" with "first"
      And I press "Search tags"
    Then I should see "2 Found"
      And I should see "Fandom: first fandom (0)"
      And I should see "Character: first last (0)" within ".canonical"
    When I am on the search tags page
      And I fill in "tag_search" with "first"
      And I select "Fandom" from "query[type]"
      And I press "Search tags"
    Then I should see "1 Found"
      And I should see "Fandom: first fandom (0)"
      And I should not see "first last"
    When I am on the search tags page
      And I fill in "tag_search" with "first"
      And I check "canonical?"
      And I press "Search tags"
    Then I should see "1 Found"
      And I should see "first last (0)" within ".canonical"
      And I should not see "Fandom: first fandom (0)"
