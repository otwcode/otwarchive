@no-txn @works @search
Feature: Search Works
  In order to test search
  As a humble coder
  I have to use cucumber with thinking sphinx
  
  # do everything that doesn't modify the works in one scenario
  # so you only have to load the fixtures and update the sphinx indexes once
  Scenario: Search works
    Given I have loaded the fixtures
      And I have Battle 12 prompt meme fully set up
      And everyone has signed up for Battle 12
    When mod fulfills claim
    When I reveal the "Battle 12" challenge
    When I am logged in as "myname4"
      And the work indexes are updated
      
    # anon work doesn't show up in searches
    When I search for works containing "mod"
    Then I should see "No results found"
    When I search for works by mod
    Then I should see "No results found"
    
    # reveal works
    When I reveal the authors of the "Battle 12" challenge
    When all search indexes are updated
    When I am logged in as "myname4"
    When I search for works containing "mod"
    Then I should see "No results found"
    When I search for works by mod
    Then I should see "No results found"
     

    # do some valid searches
    When I search for a simple term from the search box
    Then I should see "3 Found"
    When I follow "Edit Your Search"
    Then I should be on the search works page
      And all search indexes are updated
    When I fill in "Any Field" with ""
      And I fill in "Fandoms" with "second"
      And I press "Search" within "form#new_work_search"
    Then I should see "1 Found"
    When I am on the search works page
      And I select "Deutsch" from "Language"
      And I press "Search" within "form#new_work_search"
    Then I should see "1 Found"
    # When I am on the search works page
    # When I fill in "Hits" with "10000-20000"
    #   And I press "Search"
    #   Then show me the page
    # Then I should see "1 Found"
    When I am on the search works page
    When I fill in "Word Count" with ""
      And I fill in "Date" with "> 2 years ago"
      And I press "Search" within "form#new_work_search"
    Then I should see "1 Found"
    When I follow "Edit Your Search"
    Then I should be on the search works page
    When I fill in "Word Count" with ">1000"
      And I press "Search" within "form#new_work_search"
    Then I should see "No results found"
     #When I am on the search works page
       #And I have loaded the fixtures
       #And I fill in "Hits" with "> 100"
       #And I press "Search"
     #Then I should see "First work"
       #And I should see "third work"
       #And I should see "2 Found"
       #And I should see "You searched for: hits: > 100"
   When I am on the homepage.
     And I fill in "site_search" with "testuser2"
     And I press "Search"
   Then I should see "2 Found"
   When I follow "Edit Your Search"
     Then I should be on the search works page
     When I fill in "Any Field" with ""
       And I fill in "Author/Artist" with "testuser2"
      And I press "Search" within "form#new_work_search"
   Then I should see "2 Found"
#     When I am on the search works page
#       And I fill in "Kudos" with ">0"
#       And I press "Search" within "form#new_work_search"
#     Then I should see "You searched for: kudos count: >0"
#       And I should see "2 Found"
#     When I follow "Edit Your Search"
#       And I fill in "Kudos" with "5"
#       And I press "Search" within "form#new_work_search"
#     Then I should see "You searched for: Kudos: 5"
#       And I should see "No results found"
#     When I fill in "refine_text" with "kudos: 4"
#       And I press "Refine search"
#     Then I should see "You searched for: kudos count: 4"
#     Then I should see "1 Found"
#     When I follow "Edit Your Search"
#       And I fill in "Kudos" with "<2"
#       And I press "Search" within "form#new_work_search"
#     Then I should see "You searched for: kudos count: <2"
#     Then I should see "5 Found"
#
#     Then search for non-wips
#     When I follow "Edit Your Search"
#       And I check "Complete"
#       And I press "Search" within "form#new_work_search"
#     Then I should see "You searched for: kudos count: <2 Complete"
#     Then I should see "4 Found"
    # 3 from the fixtures and one from the challenge
