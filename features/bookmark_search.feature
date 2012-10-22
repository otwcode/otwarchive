@no-txn @bookmarks @search
Feature: Search Bookmarks
  In order to test search
  As a humble coder
  I have to use cucumber with thinking sphinx

  Scenario: Search bookmarks
    Given I have loaded the fixtures
    When I am on the search bookmarks page
    When I fill in "Tag" with "classic"
      And I press "Search bookmarks"
    Then I should see "1 Found"
    When I am on the search bookmarks page
      And I check "Rec"
      And I press "Search bookmarks"
    Then I should see "First work"
