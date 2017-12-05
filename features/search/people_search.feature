Feature: Search pseuds
  As a user
  I want to use search to find other users

  Background:
    Given I have loaded the fixtures
    And I am logged in as "testuser"
    And testuser can use the new search

  Scenario: Search by name
    When I go to the search people page
      And I fill in "Name:" with "testuser"
      And I press "Search People"
    Then I should see "testy"
      And I should not see "sad user"
    When I fill in "Search all fields:" with "test*"
      Then I should see "testy"
      And I should not see "sad user"

  Scenario: Search by fandom
    When I go to the search people page
      And I fill in "Fandom:" with "Ghost Soup"
      And I press "Search People"
    Then I should see "testuser2"
      And I should not see "testy"