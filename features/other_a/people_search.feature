@no-txn @search
Feature: Search People
  In order to test search
  As a humble coder
  I have to use cucumber with thinking sphinx

  @old-search
  Scenario: Search people
    Given I have loaded the fixtures
    When I am on the search people page
      And I fill in "Name or description:" with "test"
      And I press "Search people"
    Then I should see "0 Found"
    When I fill in "Name or description:" with "test*"
      And I press "Search people"
    Then I should see "6 Found"

  @new-search
  Scenario: Search people
    Given I have loaded the fixtures
    When I am on the search people page
      And I fill in "Search all fields" with "test"
      And I press "Search People"
    Then I should see "0 Found"
    When I fill in "Search all fields" with "test*"
      And I press "Search People"
    Then I should see "6 Found"
