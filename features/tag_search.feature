@no-txn @tags @tag_wrangling @search
Feature: Search Tags
  In order to find works in the archive
  As a user
  I want to search using tags

  Scenario: Search should search multiple types of tags
    Given The following tags exist
      | type         | tag                                  |
      | fandom       | searchable fandom                    |
      | character    | searchable character                 |
      | relationship | searchable character/other character |
      And the tag indexes are updated
    When I search tags for "searchable"
    Then I can see the following tags
      | type         | tag                                  |
      | fandom       | searchable fandom                    |
      | character    | searchable character                 |
      | relationship | searchable character/other character |
    
  Scenario: Search for fandom tag
    Given The fandom tag "searchable fandom" exists
      And the tag indexes are updated
    When I search for fandom tag "searchable fandom"
    Then I can see the fandom tag "searchable fandom"

  Scenario: Search tags
    Given I have no tags
      And a fandom exists with name: "first fandom"
      And a character exists with name: "first last", canonical: true
      And a relationship exists with name: "first last/someone else"
      And the tag indexes are updated
    When I am on the search tags page
      And I fill in "tag_search" with "first"
      And I press "Search tags"
    Then I should see "3 Found"
      And I should see "Fandom: first fandom (0)"
      And I should see "Character: first last (0)" within ".canonical"
      And I should see "Relationship: first last/someone else (0)"
    When I am on the search tags page
      And I fill in "tag_search" with "first"
      And I select "Fandom" from "query[type]"
      And I press "Search tags"
    Then I should see "1 Found"
      And I should see "Fandom: first fandom (0)"
      And I should not see "first last"
    When I am on the search tags page
      And I fill in "tag_search" with "first"
      And I check "canonical?"
      And I press "Search tags"
    Then I should see "1 Found"
      And I should see "first last (0)" within ".canonical"
      And I should not see "Fandom: first fandom (0)"
    # test search with slash
    When I am on the search tags page
      And I fill in "tag_search" with "first last/someone else"
      And I press "Search tags"
    Then I should see "1 Found"
      And I should see "first last/someone else (0)"
