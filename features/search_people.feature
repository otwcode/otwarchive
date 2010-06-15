@users
Feature: Search People

  Scenario: Search people
    Given I have loaded the fixtures
      And the Sphinx indexes are updated
    When I am on the search people page
      And I fill in "people_search" with "test"
      And I press "Search people"
    Then I should see "0 Found"
    When I fill in "people_search" with "test*"
      And I press "Search people"
    Then I should see "5 Found"
