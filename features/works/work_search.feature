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
      And the 1st result should contain "Language: Deutsch"
    When I follow "Edit Your Search"
    Then "Deutsch" should be selected within "Language"

  Scenario: Search by range of hits
    Given I have the Battle set loaded

    When I am on the search works page
      And I fill in "Hits" with "10000-20000"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: hits: 10000-20000"
      And I should see "1 Found"
      And the 1st result should contain "Hits: 10000"
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
    Then I should see "You searched for: word count: >15000 revised at: > 2 years ago"
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

  Scenario: Search and sort by number of kudos
    Given I have the Battle set loaded

    When I am on the search works page
      And I fill in "Kudos" with ">0"
      And I select "Kudos" from "Sort by"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: >0 sort by: kudos descending"
      And I should see "2 Found"
      And the 1st result should contain "Kudos: 4"
      And the 2nd result should contain "Kudos: 1"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain ">0"
      And "Kudos" should be selected within "Sort by"
    When I fill in "Kudos" with "5"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: 5 sort by: kudos descending"
      And I should see "No results found"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "5"
    When I fill in "Kudos" with "4"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: 4 sort by: kudos descending"
      And I should see "1 Found"
      And the 1st result should contain "Kudos: 4"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "4"
    When I fill in "Kudos" with "<2"
      And I select "Ascending" from "Sort direction"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: <2 sort by: kudos ascending"
      And I should see "6 Found"
      And I should see "second work"
      And I should see "third work"
      And I should see "fourth"
      And I should see "fifth"
      And I should see "I am <strong>er Than Yesterday & Other Lies"
      And I should see "Fulfilled Story-thing"
      And the 6th result should contain "Kudos: 1"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "<2"
      And "Kudos" should be selected within "Sort by"
    When "AO3-5020" is fixed
      # And "Ascending" should be selected within "Sort direction"
    When I check "Complete"
      And I press "Search" within "#new_work_search"
    When "AO3-5020" is fixed
    # Then I should see "You searched for: Complete kudos count: <2 sort by: kudos ascending"
      And I should see "4 Found"
      And I should see "second work"
      And I should see "third work"
      And I should see "fourth"
      And I should see "Fulfilled Story-thing"
    When "AO3-5020" is fixed
      # And the 4th result should contain "Kudos: 1"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "<2"
      And the "Complete" checkbox should be checked
    When "AO3-5020" is fixed
      # And "Ascending" should be selected within "Sort direction"

  Scenario: Search by single chapter
    Given I have the Battle set loaded

    When I am on the search works page
      And I check "Single Chapter"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Single Chapter"
      And I should see "4 Found"
      And I should see "First work"
      And I should see "second work"
      And I should see "fourth"
      And I should see "Fulfilled Story-thing"
    When I follow "Edit Your Search"
    Then the "Single Chapter" checkbox should be checked

  Scenario: Search and sort by title
    Given I have loaded the fixtures

    When I am on the search works page
      And I fill in "Title" with "work"
      And I select "Title" from "Sort by"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Title: work sort by: title descending"
      And I should see "3 Found"
      And the 1st result should contain "third work"
      And the 2nd result should contain "second work"
      And the 3rd result should contain "First work"
    When I follow "Edit Your Search"
    Then the field labeled "Title" should contain "work"
      And "Title" should be selected within "Sort by"
    When I select "Ascending" from "Sort direction" 
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Title: work sort by: title ascending"
      And I should see "3 Found"
      And the 1st result should contain "First work"
      And the 2nd result should contain "second work"
      And the 3rd result should contain "third work"
    When I follow "Edit Your Search"
    Then the field labeled "Title" should contain "work"
      And "Title" should be selected within "Sort by"
    When "AO3-5020" is fixed
      # And "Ascending" should be selected within "Sort direction"

  # TODO: Search by comments

  # TODO: Search by bookmarks

  # TODO: Search by fandoms

  # TODO: Search by rating

  # TODO: Search by warnings

  # TODO: Search by categories

  Scenario: Searching for a character in the header search returns works with (a) the exact tag, (b) the tag's syns, and (c) any other tags or text matching the search term; refining the search with the character field returns only works with the character tag or its syns
    Given a set of Steve Rogers works for searching

    When I search for works containing "Steve Rogers"
    Then I should see "You searched for: Steve Rogers"
      And I should see "6 Found"
      And the results should contain the character tag "Steve Rogers"
      And the results should contain the character tag "Captain America"
      And the results should contain the relationship tag "Steve Rogers/Tony Stark"
      And the results should contain a summary mentioning "Steve Rogers"
    When I follow "Edit Your Search"
    Then the field labeled "Any Field" should contain "Steve Rogers"
    When I fill in "Characters" with "Steve Rogers"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Steve Rogers Tags: Steve Rogers"
      And I should see "4 Found"
      And the results should contain the character tag "Steve Rogers"
      And the results should contain the character tag "Captain America"
      And the results should not contain the relationship tag "Steve Rogers/Tony Stark"
      And the results should not contain a summary mentioning "Steve Rogers"

  Scenario: Searching by character for a tag with synonyms returns works using
  the exact tag or its synonyms
    Given a set of Steve Rogers works for searching

    When I am on the search works page
      And I fill in "Characters" with "Steve Rogers"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Steve Rogers"
      And I should see "4 Found"
      And the results should contain the character tag "Steve Rogers"
      And the results should contain the character tag "Captain America"
      And the results should not contain the relationship tag "Steve Rogers/Tony Stark"
      And the results should not contain a summary mentioning "Steve Rogers"
    When I follow "Edit Your Search"
    Then the field labeled "Characters" should contain "Steve Rogers"

  Scenario: Searching by relationship for a tag with synonyms returns works
  using the exact tag or its synonyms
    Given a set of Kirk/Spock works for searching

    When I am on the search works page
      And I fill in "Relationships" with "James T. Kirk/Spock"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: James T. Kirk/Spock"
      And I should see "4 Found"
      And the results should contain the relationship tag "James T. Kirk/Spock"
      And the results should contain the relationship tag "Spirk"
      And the results should contain the relationship tag "K/S"
    When I follow "Edit Your Search"
    Then the field labeled "Relationships" should contain "James T. Kirk/Spock"

  Scenario: Searching by relationship and category
    Given a set of Kirk/Spock works for searching

    When I am on the search works page
      And I fill in "Relationships" with "James T. Kirk/Spock"
      And I check "F/M"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: F/M, James T. Kirk/Spock"
      And I should see "1 Found"
      And I should see "The Genderswap K/S Work That Uses a Synonym"
    When I follow "Edit Your Search"
    Then the field labeled "Relationships" should contain "James T. Kirk/Spock"
      And the "F/M" checkbox should be checked

  Scenario: Searching for a pairing in the header search returns threesomes that
  partially match the search, but refining it with the relationship field will
  not
    Given a set of Spock/Uhura works for searching

    When I search for works containing "Spock/Nyota Uhura"
    Then I should see "You searched for: Spock/Nyota Uhura"
      And I should see "3 Found"
      And the results should contain the relationship tag "Spock/Nyota Uhura"
      And the results should contain the relationship tag "James T. Kirk/Spock/Nyota Uhura"
    When I follow "Edit Your Search"
    Then the field labeled "Any Field" should contain "Spock/Nyota Uhura"
    When I fill in "Relationships" with "Spock/Nyota Uhura"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Spock/Nyota Uhura Tags: Spock/Nyota Uhura"
      And the results should contain the relationship tag "Spock/Nyota Uhura"
      And the results should not contain the relationship tag "James T. Kirk/Spock/Nyota Uhura"

  Scenario: Searching by additional tags (freeforms) for a metatag with synonyms
  and subtags should return works using the tag, its synonyms, its subtags, and
  its subtags' synonyms
    Given a set of alternate universe works for searching

    When I am on the search works page
      And I fill in "Additional Tags" with "Alternate Universe"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Alternate Universe"
      And I should see "4 Found"
      And the results should contain the freeform tag "Alternate Universe"
      And the results should contain the freeform tag "AU"
      And the results should contain the freeform tag "High School AU"
      And the results should contain the freeform tag "Alternate Universe - Coffee Shops & Cafés"
      And the results should not contain the freeform tag "Coffee Shop AU"
    When I follow "Edit Your Search"
    Then the field labeled "Additional Tags" should contain "Alternate Universe"

  Scenario: Search by additional tags (freeforms) using a tag with no direct
  uses, but a synonym that has been used
    Given a set of alternate universe works for searching

    When I am on the search works page
      And I fill in "Additional Tags" with "Alternate Universe - High School"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Alternate Universe - High School"
      And I should see "1 Found"
      And the results should contain the freeform tag "High School AU"
    When I follow "Edit Your Search"
    Then the field labeled "Additional Tags" should contain "Alternate Universe - High School"

  Scenario: Search by additional tags (freeforms) using a tag that has not been
  wrangled
    Given a set of alternate universe works for searching

    When I am on the search works page
      And I fill in "Additional Tags" with "Coffee Shop AU"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Coffee Shop AU"
      And I should see "1 Found"
      And the results should contain the freeform tag "Coffee Shop AU"
      And the results should not contain the freeform tag "Alternate Universe - Coffee Shops & Cafés"

  # TODO: Results for logged out user should not contain restricted work

  # TODO: Results for logged in user should contain restricted work