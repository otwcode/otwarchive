Feature: Search pseuds
  As a user
  I want to use search to find other users

  Background:
    Given I have loaded the fixtures
    And I am logged in as "testuser" with password "testing"
    And testuser can use the new search

  Scenario: Search by name
    When I go to the search people page
      And I fill in "Search all fields:" with "testuser"
      And I press "Search people"
    Then I should see "testy"
      And I should not see "sad user"

  Scenario: Search by fandom
    When I go to the search people page
      And I fill in "Fandom:" with "Ghost Soup"
      And I press "Search people"
    Then I should see "testuser2"
      And I should not see "testy"