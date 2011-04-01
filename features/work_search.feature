@no-txn @works @search
Feature: Search Works
  In order to test search
  As a humble coder
  I have to use cucumber with thinking sphinx

  # do everything that doesn't modify the works in one scenario
  # so you only have to load the fixtures and update the sphinx indexes once
  Scenario: Search works
    Given I have loaded the fixtures
      And the work indexes are updated

    # first check the errors for an invalid search
    When I am on the homepage
      And I fill in "site_search" with "Tag: harry potter Words: >1000 (Language: Deutsch | Tag: Deutsch)"
      And I press "Search"
    Then I should see "bad words format (ignored)"
      And I should see "0 Found"

    # then do some valid searches
    When I am on the homepage
      And I fill in "site_search" with "(title,summary): second words: >100"
      And I press "Search"
    Then I should see "Text: (title,summary): second"
      And I should see "Words: >100"
      And I should see "2 Found"
      And I should not see "First work"
      And I should see "second work"
      And I should see "third work"
      And I should not see "fourth"
    When I am on the homepage
      And I fill in "site_search" with "first"
      And I press "Search"
    Then I should see "3 Found"
    When I follow "Advanced search"
    Then I should be on the search page
    When I fill in "refine_text" with ""
      And I fill in "refine_tag" with "second"
      And I press "Search works"
    Then I should see "1 Found"
    When I am on the search page
      And I select "Deutsch" from "Language:"
      And I press "Search works"
    Then I should see "1 Found"
    When I am on the homepage
      And I fill in "site_search" with "hits: 0-10"
      And I press "Search"
    Then I should see "3 Found"
    When I am on the homepage
      And I fill in "site_search" with "hits: >10"
      And I press "Search"
    Then I should see "2 Found"
    When I follow "Advanced search"
    Then I should be on the search page
    When I fill in "refine_hit_count" with "10000-20000"
      And I press "Search works"
    Then I should see "1 Found"
    When I am on the homepage
      And I fill in "site_search" with "words: 50-150"
      And I press "Search"
    Then I should see "1 Found"
    When I am on the homepage
      And I fill in "site_search" with "words: >100 language:english"
      And I press "Search"
    Then I should see "2 Found"
    When I follow "Advanced search"
    Then I should be on the search page
    When I fill in "refine_word_count" with ""
      And I fill in "refine_revised_at" with "> 2 years ago"
      And I press "Search works"
    Then I should see "1 Found"
    When I follow "Advanced search"
    Then I should be on the search page
    When I fill in "refine_word_count" with "<1000"
      And I press "Search works"
    Then I should see "0 Found"
    When I am on the search page
      And I fill in "refine_hit_count" with "> 1.000"
      And I press "Search works"
    Then I should see "First work"
      And I should see "third work"
      And I should see "2 Found"
      And I should see "You searched for: Hits: > 1000"
    When I fill in "refine_text" with "hits: >9,000"
      And I press "Refine search"
    Then I should see "You searched for: Hits: >9000"
      And I should see "1 Found"
      And I should not see "First work"
      And I should see "third work"
   When I am on the homepage.
     And I fill in "site_search" with "testuser2"
     And I press "Search"
   Then I should see "2 Found"
   When I follow "Advanced search"
     Then I should be on the search page
     When I fill in "refine_text" with ""
       And I fill in "refine_author" with "testuser"
       And I press "Search"
   Then I should see "5 Found"
    When I am on the search page
      And I fill in "Kudos" with ">0"
      And I press "Search works"
    Then I should see "You searched for: Kudos: >0"
      And I should see "2 Found"
    When I follow "Advanced search"
      And I fill in "Kudos" with "5"
      And I press "Search works"
    Then I should see "You searched for: Kudos: 5"
      And I should see "0 Found"
    When I fill in "refine_text" with "kudos: 4"
      And I press "Refine search"
    Then I should see "You searched for: Kudos: 4"
    Then I should see "1 Found"
    When I follow "Advanced search"
      And I fill in "Kudos" with "<2"
      And I press "Search works"
    Then I should see "You searched for: Kudos: <2"
    Then I should see "4 Found"

