@no-txn @works @search
Feature: Search Works
  In order to test search
  As a humble coder
  I have to use Cucumber with Elasticsearch

  Scenario: Works that are anonymous do not show up in searches for the
  creator's name
      Given I have the Battle set loaded
      When I search for works containing "mod1"
      Then I should see "You searched for: mod1"
        And I should see "No results found"
      When I search for works by "mod1"
      Then I should see "You searched for: creator: mod1"
        And I should see "No results found"

  Scenario: Works that are anonymous should show up in searches for the
  creator Anonymous
    Given I have the Battle set loaded
    When I search for works containing "Anonymous"
    Then I should see "You searched for: Anonymous"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I search for works by "Anonymous"
    Then I should see "You searched for: creator: Anonymous"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I go to the search works page
      And I fill in "Author/Artist" with "Anonymous"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Author/Artist: Anonymous"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"

  Scenario: Works that used to be anonymous show up in searches for the
  creator's name once the creator is revealed
    Given I have the Battle set loaded
      And I reveal the authors of the "Battle 12" challenge
      And all search indexes are updated
    When I search for works containing "mod1"
    Then I should see "You searched for: mod1"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I search for works by "mod1"
    Then I should see "You searched for: creator: mod1"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I go to the search works page
      And I fill in "Author/Artist" with "mod1"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Author/Artist: mod1"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"

  Scenario: Search by language
    Given I have the Battle set loaded

    When I am on the search works page
      And I select "Deutsch" from "Language"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Language: Deutsch"
      And I should see "1 Found"
    When I follow "Edit Your Search"
    Then "Deutsch" should be selected within "Language"

  Scenario: Search by range of hits
    Given I have the Battle set loaded

    When I am on the search works page
      And I fill in "Hits" with "10000-20000"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: hits: 10000-20000"
      And I should see "1 Found"
      And I should see "third work"
    When I follow "Edit Your Search"
    Then the field labeled "Hits" should contain "10000-20000"

  Scenario: Search by date and then refine by word count
    Given I have the Battle set loaded

    When I am on the search works page
      And I fill in "Date" with "> 2 years ago"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: revised at: > 2 years ago"
      And I should see "6 Found"
      And I should see "First work"
      And I should see "second work"
      And I should see "third work"
      And I should see "fourth"
      And I should see "fifth"
      And I should see "I am <strong>er Than Yesterday & Other Lies"
    When I follow "Edit Your Search"
    Then I should be on the search works page
      And the field labeled "Date" should contain "> 2 years ago"
    When I fill in "Word Count" with ">15000"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: word count: >1500 revised at: > 2 years ago"
      And I should see "No results found"

  Scenario: Search by > hits
    Given I have the Battle set loaded

    When I am on the search works page
      And I fill in "Hits" with "> 100"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: hits: > 100"
      And I should see "2 Found"
      And I should see "First work"
      And I should see "third work"
    When I follow "Edit Your Search"
    Then the field labeled "Hits" should contain "> 100"

  Scenario: Search with the header search field and then refine by author/artist
    Given I have the Battle set loaded

    When I fill in "site_search" with "testuser2"
      And I press "Search"
    Then I should see "You searched for: testuser2"
      And I should see "3 Found"
      And I should see "I am <strong>er Than Yesterday & Other Lies"
      And I should see "fourth"
      And I should see "fifth"
    When I follow "Edit Your Search"
    Then I should be on the search works page
      And the field labeled "Any Field" should contain "testuser2"
    When I fill in "Any Field" with ""
      And I fill in "Author/Artist" with "testuser2"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Author/Artist: testuser2"
      And I should see "3 Found"
      And I should see "fourth"
      And I should see "fifth"
      And I should see "I am <strong>er Than Yesterday & Other Lies"

  Scenario: Search by number of kudos
    Given I have the Battle set loaded

    When I am on the search works page
      And I fill in "Kudos" with ">0"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: >0"
      And I should see "2 Found"
      And I should see "First work"
      And I should see "second work"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain ">0"
    When I fill in "Kudos" with "5"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: 5"
      And I should see "No results found"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "5"
    When I fill in "Kudos" with "4"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: 4"
      And I should see "1 Found"
      And I should see "First work"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "4"
    When I fill in "Kudos" with "<2"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: <2"
      And I should see "6 Found"
      And I should see "second work"
      And I should see "third work"
      And I should see "fourth"
      And I should see "fifth"
      And I should see "I am <strong>er Than Yesterday & Other Lies"
      And I should see "Fulfilled Story-thing"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "<2"
    When I check "Complete"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Complete kudos count: <2"
      And I should see "4 Found"
      And I should see "second work"
      And I should see "third work"
      And I should see "fourth"
      And I should see "Fulfilled Story-thing"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "<2"
      And the "Complete" checkbox should be checked

  # TODO: Search by single chapter

  # TODO: Search by title

  # TODO: Search by comments

  # TODO: Search by bookmarks

  # TODO: Search by fandoms

  # TODO: Search by rating

  # TODO: Search by warnings

  # TODO: Search by categories

  # TODO: Search by characters

  # TODO: Search by relationships

  # TODO: Search by additional tags

  # TODO: Results for logged out user should not contain restricted work

  # TODO: Results for logged in user should contain restricted work