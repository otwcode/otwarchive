Feature: Search pseuds
  As a user
  I want to use search to find other users

  Scenario: Search by name
    Given the following activated users exists
      | login                   |
      | testuser                |
      | sad_user_with_no_pseuds |
      And "testuser" has the pseud "testy"
      And "testuser" has the pseud "tester_pseud"
      And "testuser" has the pseud "testymctesty"
      And I am logged in as "testuser"
    When I go to the search people page
      And I fill in "Name" with "testuser"
      And I press "Search People"
    Then I should see "testy"
      And I should not see "sad_user_with_no_pseuds"

    When I fill in "Search all fields" with "test"
      And I press "Search People"
    Then I should see "0 Found"

    When I fill in "Search all fields" with "test*"
      And I press "Search People"
    Then I should see "4 Found"
      And I should see "testy"
      And I should not see "sad_user_with_no_pseuds"

  Scenario: Search by fandom
    Given a canonical fandom "Ghost Soup"
      And a canonical fandom "Bread"
      And the work "soup" by "testuser2" with fandom "Ghost Soup"
      And the work "toast" by "testy" with fandom "Bread"
      And all indexing jobs have been run
      And I am logged in as "testuser"
    When I go to the search people page
      And I fill in "Fandom" with "Ghost Soup"
      And I press "Search People"
    Then I should see "testuser2"
      And I should not see "testy"

  Scenario: Search by fandom updates when a work is posted.
    Given a canonical fandom "Ghost Soup"
      And I am logged in as "testuser"
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
    When I edit the work "Drabble Collection"
      And I fill in "Fandom" with "MCU, Ghost Soup"
      And I press "Update"
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
    When I edit the work "Drabble Collection"
      And I fill in "Fandom" with "MCU"
      And I press "Update"
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
    When I edit the work "Drabble Collection"
      And I invite the co-author "alice"
      And I press "Update"
      And all indexing jobs have been run
      And I go to the search people page
      And I fill in "Fandom" with "Ghost Soup"
      And I press "Search People"
    Then I should see "testuser" within "ol.pseud.group"
      But I should not see "alice" within "ol.pseud.group"
    When the user "alice" accepts all co-creator requests
      And all indexing jobs have been run
      And I go to the search people page
      And I fill in "Fandom" with "Ghost Soup"
      And I press "Search People"
    Then I should see "testuser" within "ol.pseud.group"
      And I should see "alice" within "ol.pseud.group"

  Scenario: Search by fandom updates when an author is removed from a work.
    Given a canonical fandom "Ghost Soup"
      And I am logged in as "testuser"
      And I post the work "Drabble Collection" with fandom "Ghost Soup"
      And I add the co-author "alice" to the work "Drabble Collection"
      And all indexing jobs have been run
    When I edit the work "Drabble Collection"
      And I press "Remove Me As Co-Creator"
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
    When I orphan the work "Drabble Collection"
      And all indexing jobs have been run
      And I go to the search people page
      And I fill in "Fandom" with "Ghost Soup"
      And I press "Search People"
    Then I should see "orphan_account" within "ol.pseud.group"
      But I should not see "testuser" within "ol.pseud.group"
