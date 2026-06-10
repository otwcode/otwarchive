@works @search
Feature: Search anonymous works
  As a creator of anonymous works
  I do not want searching for my name to ruin my anonymity
  But I do want my works to appear in searches

  Scenario: Works that are anonymous do not show up in searches for the
    creator's name
    Given I have the anonymous collection "Battle 12"
      And I am logged in as "moderator"
      And I post the work "Fulfilled Story-thing" in the collection "Battle 12"
    When I search for works containing "moderator"
    Then I should see "You searched for: moderator"
      And I should see "No results found"
    When I search for works by "moderator"
    Then I should see "You searched for: creator: moderator"
      And I should see "No results found"

  Scenario: Works that are anonymous should show up in searches for the
  creator Anonymous
    Given I have the anonymous collection "Battle 12"
      And I am logged in as "moderator"
      And I post the work "Fulfilled Story-thing" in the collection "Battle 12"
    When I search for works containing "Anonymous"
    Then I should see "You searched for: Anonymous"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I search for works by "Anonymous"
    Then I should see "You searched for: creator: Anonymous"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I go to the search works page
      And I fill in "Creator" with "Anonymous"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Creator: Anonymous"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"

  Scenario: Works that used to be anonymous show up in searches for the
  creator's name once the creator is revealed
    Given I have the anonymous collection "Battle 12"
      And I am logged in as "moderator"
      And I post the work "Fulfilled Story-thing" in the collection "Battle 12"
      And I reveal authors for "Battle 12"
      And all indexing jobs have been run
    When I search for works containing "moderator"
    Then I should see "You searched for: moderator"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I search for works by "moderator"
    Then I should see "You searched for: creator: moderator"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I go to the search works page
      And I fill in "Creator" with "moderator"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Creator: moderator"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
