@no-txn @bookmarks @search
Feature: Search Bookmarks
  In order to test search
  As a humble coder
  I have to use cucumber with elasticsearch

  Background:
    Given I am on the search bookmarks page

  Scenario: Search bookmarks by tag
    Given I have bookmarks to search
    When I fill in "Tag" with "classic"
      And I press "Search bookmarks"
    Then I should see the page title "Search Bookmarks"
      And I should see "You searched for: Tags: classic"
      And I should see "1 Found"
      And I should see "third work"
    When I follow "Edit Your Search"
    Then the field labeled "Tag" should contain "classic"

  Scenario: Search bookmarks by date bookmarked
    Given I have bookmarks to search by dates
    When I fill in "Date Bookmarked" with "> 900 days ago"
      And I press "Search bookmarks"
    Then I should see the page title "Search Bookmarks"
      And I should see "You searched for: Date bookmarked: > 900 days ago"
      And I should see "1 Found"
      And I should see "Old bookmark of old work"
    When I follow "Edit Your Search"
    Then the field labeled "Date Bookmarked" should contain "> 900 days ago"

    When I fill in "Date Bookmarked" with "< 900 days ago"
      And I press "Search bookmarks"
    Then I should see "You searched for: Date bookmarked: < 900 days ago"
      And I should see "2 Found"
      And I should see "New bookmark of old work"
      And I should see "New bookmark of new work"

  Scenario: Search bookmarks by date updated
    Given I have bookmarks to search by dates
    When I fill in "Date Updated" with "> 900 days ago"
      And I press "Search bookmarks"
    Then I should see the page title "Search Bookmarks"
      And I should see "You searched for: Date updated: > 900 days ago"
      And I should see "2 Found"
      And I should see "Old bookmark of old work"
      And I should see "New bookmark of old work"
    When I follow "Edit Your Search"
    Then the field labeled "Date Updated" should contain "> 900 days ago"

    When I fill in "Date Updated" with "< 900 days ago"
      And I press "Search bookmarks"
    Then I should see "You searched for: Date updated: < 900 days ago"
      And I should see "1 Found"
      And I should see "New bookmark of new work"

  Scenario: Search bookmarks for recs
    Given I have bookmarks to search
    When I check "Rec"
      And I press "Search bookmarks"
    Then I should see the page title "Search Bookmarks"
      And I should see "You searched for: Rec"
      And I should see "1 Found"
      And I should see "First work"
    When I follow "Edit Your Search"
    Then the "Rec" checkbox should be checked

  Scenario: Search bookmarks by any field
    Given I have bookmarks to search
    When I fill in "Any field" with "Hobbits"
      And I press "Search bookmarks"
    Then I should see the page title "Bookmarks Matching 'Hobbits'"
      And I should see "You searched for: Hobbits"
      And I should see "No results found."
    When I follow "Edit Your Search"
    Then the field labeled "Any field" should contain "Hobbits"

  Scenario: Search bookmarks by type
    Given I have bookmarks to search
    When I select "External Work" from "Type"
      And I press "Search bookmarks"
    Then I should see the page title "Search Bookmarks"
      And I should see "You searched for: Type: External Work"
      And I should see "1 Found"
      And I should see "Skies Grown Darker"
    When I follow "Edit Your Search"
    When "AO3-3583" is fixed
    # Then "External Work" should be selected within "Type"

  Scenario: Search for bookmarks with notes, and then edit search to narrow
  results by the note content
    Given I have bookmarks to search
    When I check "With Notes"
      And I press "Search bookmarks"
    Then I should see the page title "Search Bookmarks"
      And I should see "You searched for: With Notes"
      And I should see "2 Found"
      And I should see "fifth"
      And I should see "Skies Grown Darker"
    When I follow "Edit Your Search"
    Then the "With Notes" checkbox should be checked
    When I fill in "Notes" with "broken heart"
      And I press "Search bookmarks"
    Then I should see the page title "Search Bookmarks"
      And I should see "You searched for: Notes: broken heart, With Notes"
    When "AO3-3943" is fixed
      # And I should see "1 Found"
      # And I should see "fifth"
    When I follow "Edit Your Search"
    Then the field labeled "Notes" should contain "broken heart"
      And the "With Notes" checkbox should be checked

  Scenario: If testuser has the pseud tester_pseud, searching for bookmarks by
  the bookmarker testuser returns all of tester_pseud's bookmarks
    Given I have bookmarks to search
    When I fill in "Bookmarker" with "testuser"
      And I press "Search bookmarks"
    Then I should see the page title "Search Bookmarks"
      And I should see "You searched for: Bookmarker: testuser"
      And I should see "6 Found"
      And I should see "First work"
      And I should see "second work"
      And I should see "third work"
      And I should see "tester_pseud"
      And I should see "fifth"
      And I should see "Skies Grown Darker"
    When I follow "Edit Your Search"
    Then the field labeled "Bookmarker" should contain "testuser"
