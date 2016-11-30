@no-txn @works @search
Feature: Search Works
  In order to test search
  As a humble coder
  I have to use cucumber with thinking sphinx
  
  # do everything that doesn't modify the works in one scenario
  # so you only have to load the fixtures and update the sphinx indexes once
  Scenario: anon work doesn't show up in searches
    Given I have the Battle set loaded
      
      When I search for works containing "mod"
      Then I should see "No results found"
      When I search for works by mod
      Then I should see "No results found"
    
  Scenario: reveal works doesn't show up in searches
    Given I have the Battle set loaded

    When I reveal the authors of the "Battle 12" challenge
      And all search indexes are updated
      And I am logged in as "myname4"
      And I search for works containing "mod"
    Then I should see "No results found"
    When I search for works by mod
    Then I should see "No results found"

  Scenario:  do some valid searches
    Given I have the Battle set loaded

    When I search for a simple term from the search box
    Then I should see "3 Found"
    When I follow "Edit Your Search"
    Then I should be on the search works page
      And all search indexes are updated
    When I fill in "Any Field" with ""
      And I fill in "Fandoms" with "second"
      And I press "Search" within "form#new_work_search"
    Then I should see "1 Found"

  Scenario: search by language
    Given I have the Battle set loaded

    When I am on the search works page
      And I select "Deutsch" from "Language"
      And I press "Search" within "form#new_work_search"
    Then I should see "1 Found"

  Scenario: search by range of hits
    Given I have the Battle set loaded

    When I am on the search works page
      And I fill in "Hits" with "10000-20000"
      And I press "Search" within "form#new_work_search"
    Then I should see "1 Found"

  Scenario: search by date and then by word count AND date
    Given I have the Battle set loaded

    When I am on the search works page
      And I fill in "Date" with "> 2 years ago"
      And I press "Search" within "form#new_work_search"
    Then I should see "6 Found"
    When I follow "Edit Your Search"
    Then I should be on the search works page
    When I fill in "Word Count" with ">15000"
      And I press "Search" within "form#new_work_search"
    Then I should see "No results found"

  Scenario: search by > hits
    Given I have the Battle set loaded

    When I am on the search works page
      And I fill in "Hits" with "> 100"
      And I press "Search" within "form#new_work_search"
    Then I should see "2 Found"
      And I should see "First work"
      And I should see "third work"
      And I should see "You searched for: hits: > 100"

  Scenario: search with the header search field and then refine it using the author/artist field
    Given I have the Battle set loaded
    
    When I am on the homepage.
      And I fill in "site_search" with "testuser2"
      And I press "Search"
    Then I should see "3 Found"
    When I follow "Edit Your Search"
    Then I should be on the search works page
    When I fill in "Any Field" with ""
      And I fill in "Author/Artist" with "testuser2"
      And I press "Search" within "form#new_work_search"
    Then I should see "3 Found"

  Scenario: search by number of kudos
    Given I have the Battle set loaded

    When I am on the search works page
      And I fill in "Kudos" with ">0"
      And I press "Search" within "form#new_work_search"
    Then I should see "You searched for: kudos count: >0"
      And I should see "2 Found"
    When I follow "Edit Your Search"
      And I fill in "Kudos" with "5"
      And I press "Search" within "form#new_work_search"
    Then I should see "You searched for: kudos count: 5"
      And I should see "No results found"
    When I follow "Edit Your Search"
      And I fill in "Kudos" with "4"
      And I press "Search" within "form#new_work_search"
    Then I should see "You searched for: kudos count: 4"
      And I should see "1 Found"
    When I follow "Edit Your Search"
      And I fill in "Kudos" with "<2"
      And I press "Search" within "form#new_work_search"
    Then I should see "You searched for: kudos count: <2"
      And I should see "6 Found"
    When I follow "Edit Your Search"
      And I check "Complete"
      And I press "Search" within "form#new_work_search"
    Then I should see "You searched for: Complete kudos count: <2"
      And I should see "4 Found"
