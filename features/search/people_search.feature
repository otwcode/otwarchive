Feature: Search pseuds
  As a user
  I want to use search to find other users

  Scenario: Search by name
    Given I have loaded the fixtures
      And I am logged in as "testuser"
      And testuser can use the new search
    When I go to the search people page
      And I fill in "Name" with "testuser"
      And I press "Search People"
    Then I should see "testy"
      And I should not see "sad user"
    When I fill in "Search all fields" with "test*"
      Then I should see "testy"
      And I should not see "sad user"

  Scenario: Search by fandom
    Given I have loaded the fixtures
      And I am logged in as "testuser"
      And testuser can use the new search
    When I go to the search people page
      And I fill in "Fandom" with "Ghost Soup"
      And I press "Search People"
    Then I should see "testuser2"
      And I should not see "testy"

  Scenario: Search by fandom updates when a work is posted.
    Given a canonical fandom "Ghost Soup"
      And I am logged in as "testuser"
      And testuser can use the new search
    When I post a work "Drabble Collection" with fandom "Ghost Soup"
      And all indexing jobs have been run
      And I go to the search people page
      And I fill in "Fandom" with "Ghost Soup"
      And I press "Search People"
    Then I should see "testuser" within "ol.pseud.group"

  Scenario: Search by fandom updates when a fandom is added to a work.
    Given a canonical fandom "Ghost Soup"
      And I am logged in as "testuser"
      And I post the work "Drabble Collection" with fandom "MCU"
      And all indexing jobs have been run
      And testuser can use the new search
    When I edit the work "Drabble Collection"
      And I fill in "Fandom" with "MCU, Ghost Soup"
      And I press "Post Without Preview"
      And all indexing jobs have been run
      And I go to the search people page
      And I fill in "Fandom" with "Ghost Soup"
      And I press "Search People"
    Then I should see "testuser" within "ol.pseud.group"

  Scenario: Search by fandom updates when a fandom is removed from a work.
    Given a canonical fandom "Ghost Soup"
      And I am logged in as "testuser"
      And I post the work "Drabble Collection" with fandom "MCU, Ghost Soup"
      And all indexing jobs have been run
      And testuser can use the new search
    When I edit the work "Drabble Collection"
      And I fill in "Fandom" with "MCU"
      And I press "Post Without Preview"
      And all indexing jobs have been run
      And I go to the search people page
      And I fill in "Fandom" with "Ghost Soup"
      And I press "Search People"
    Then I should not see "testuser" within "ol.pseud.group"

  Scenario: Search by fandom updates when an author is added to a work.
    Given a canonical fandom "Ghost Soup"
      And I am logged in as "testuser"
      And I post the work "Drabble Collection" with fandom "Ghost Soup"
      And all indexing jobs have been run
      And testuser can use the new search
    When I edit the work "Drabble Collection"
      And I add the co-author "alice"
      And I press "Post Without Preview"
      And all indexing jobs have been run
      And I go to the search people page
      And I fill in "Fandom" with "Ghost Soup"
      And I press "Search People"
    Then I should see "testuser" within "ol.pseud.group"
      And I should see "alice" within "ol.pseud.group"

  Scenario: Search by fandom updates when an author is removed from a work.
    Given a canonical fandom "Ghost Soup"
      And I am logged in as "testuser"
      And I set up a draft "Drabble Collection" with fandom "Ghost Soup"
      And I add the co-author "alice"
      And I press "Post Without Preview"
      And all indexing jobs have been run
      And testuser can use the new search
    When I edit the work "Drabble Collection"
      And I follow "Remove Me As Author"
      And all indexing jobs have been run
      And I go to the search people page
      And I fill in "Fandom" with "Ghost Soup"
      And I press "Search People"
    Then I should see "alice" within "ol.pseud.group"
      But I should not see "testuser" within "ol.pseud.group"

  Scenario: Search by fandom updates when a work is orphaned.
    Given a canonical fandom "Ghost Soup"
      And I have an orphan account
      And I am logged in as "testuser"
      And I post the work "Drabble Collection" with fandom "Ghost Soup"
      And all indexing jobs have been run
      And testuser can use the new search
    When I orphan the work "Drabble Collection"
      And all indexing jobs have been run
      And I go to the search people page
      And I fill in "Fandom" with "Ghost Soup"
      And I press "Search People"
    Then I should see "orphan_account" within "ol.pseud.group"
      But I should not see "testuser" within "ol.pseud.group"
