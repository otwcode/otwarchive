@no-txn @tags @tag_wrangling @search
Feature: Search Tags
  In order to find tags
  As a user
  I want to use tag search

  Scenario: Search tags
    Given I have no tags
      And a fandom exists with name: "first fandom", canonical: false
      And a character exists with name: "first last", canonical: true
      And a relationship exists with name: "first last/someone else", canonical: false
      And all indexing jobs have been run
    When I am on the search tags page
      And I fill in "tag_search" with "first"
      And I press "Search tags"
    Then I should see "3 Found"
      And I should see the tag search result "Fandom: first fandom (0)"
      And I should not see the tag search result "Fandom: first fandom (0)" within ".canonical"
      And I should see the tag search result "Character: first last (0)" within ".canonical"
      And I should see the tag search result "Relationship: first last/someone else (0)"
    When I am on the search tags page
      And I fill in "tag_search" with "first"
      And I select "Fandom" from "query[type]"
      And I press "Search tags"
    Then I should see "1 Found"
      And I should see the tag search result "Fandom: first fandom (0)"
      And I should not see the tag search result "first last"
    When I am on the search tags page
      And I fill in "tag_search" with "first"
      And I check "canonical"
      And I press "Search tags"
    Then I should see "1 Found"
      And I should see the tag search result "first last (0)" within ".canonical"
      And I should not see the tag search result "Fandom: first fandom (0)"
  # test search with slash
    When I am on the search tags page
      And I fill in "tag_search" with "first last\/someone else"
      And I press "Search tags"
    Then I should see "1 Found"
      And I should see the tag search result "first last/someone else (0)"

    Scenario: Search for fandom with slash in name
      Given I have no tags
        And a fandom exists with name: "first/fandom", canonical: false
        And all indexing jobs have been run
      When I am on the search tags page
        And I fill in "tag_search" with "first"
        And I press "Search tags"
      Then I should see "1 Found"
        And I should see the tag search result "Fandom: first/fandom (0)"

    Scenario: Search for fandom with period in name
      Given I have no tags
        And a fandom exists with name: "first.fandom", canonical: false
        And all indexing jobs have been run
      When I am on the search tags page
        And I fill in "tag_search" with "first.fandom"
        And I press "Search tags"
      Then I should see "1 Found"
        And I should see the tag search result "Fandom: first.fandom (0)"
      When I follow "first.fandom"
      Then I should see "This tag belongs to the Fandom Category"
      # If this was a bug, it's fixed now?
      # When I am on the search tags page
      # possibly a bug rather than desired behaviour, to be discussed later
      #   And I fill in "tag_search" with "first"
      #   And I press "Search tags"
      # Then I should see "0 Found"
      #   And I should not see "Fandom: first.fandom (0)"
