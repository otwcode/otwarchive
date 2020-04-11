@javascript
Feature: Hit Counts
  Background:
    Given I limit myself to the Archive

  # Throughout these tests, we use the "all hit count information is reset"
  # step because logging in/logging out may result in the user being redirected
  # to the page that the user was just on, i.e. the work whose hit count we're
  # trying to test.
  #
  # We also use the "I wait 1 second" step to make sure that the browser has
  # enough time to access the hit_count endpoint.

  Scenario: When the owner views their own work, it doesn't increment the hit count
    Given the work "Hit Count Test"
      And I am logged in as the author of "Hit Count Test"
      And all hit count information is reset
    When I go to the work "Hit Count Test"
      And I wait 1 second
      And the hit counts for all works are updated
      And I go to the work "Hit Count Test"
    Then I should see "Hits:0"

  Scenario: Viewing a work logged-in increments the hit count
    Given the work "Hit Count Test"
      And I am logged in as "viewer"
      And all hit count information is reset
    When I go to the work "Hit Count Test"
      And I wait 1 second
      And the hit counts for all works are updated
      And I go to the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing a work logged-out increments the hit count
    Given the work "Hit Count Test"
      And all hit count information is reset
    When I go to the work "Hit Count Test"
      And I wait 1 second
      And the hit counts for all works are updated
      And I go to the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing an unrevealed work doesn't increment the hit count
    Given there is a work "Hit Count Test" in an unrevealed collection "Unrevealed"
      And I am logged in as "moderator"
      And all hit count information is reset
    When I go to the work "Hit Count Test"
      And I wait 1 second
      And the hit counts for all works are updated
      And I go to the work "Hit Count Test"
    Then I should see "Hits:0"

  Scenario: Viewing a work hidden by an admin doesn't increment the hit count
    Given the spam work "Hit Count Test"
      And I am logged in as an admin
      And all hit count information is reset
    When I go to the work "Hit Count Test"
      And I wait 1 second
      And the hit counts for all works are updated
      And I go to the work "Hit Count Test"
    Then I should see "Hits:0"

  Scenario: Viewing the first chapter logged-in increments the hit count
    Given the chaptered work "Hit Count Test"
      And all hit count information is reset
      And I am logged in as "viewer"
    When I go to the 1st chapter of the work "Hit Count Test"
      And I wait 1 second
      And the hit counts for all works are updated
      And I go to the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing the first chapter logged-out increments the hit count
    Given the chaptered work "Hit Count Test"
      And all hit count information is reset
    When I go to the 1st chapter of the work "Hit Count Test"
      And I wait 1 second
      And the hit counts for all works are updated
      And I go to the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing the second chapter logged-in increments the hit count
    Given the chaptered work "Hit Count Test"
      And I am logged in as "viewer"
      And all hit count information is reset
    When I go to the 2nd chapter of the work "Hit Count Test"
      And I wait 1 second
      And the hit counts for all works are updated
      And I go to the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing the second chapter logged-out increments the hit count
    Given the chaptered work "Hit Count Test"
      And all hit count information is reset
    When I go to the 2nd chapter of the work "Hit Count Test"
      And I wait 1 second
      And the hit counts for all works are updated
      And I go to the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing multiple chapters in sequence only increments the hit count once
    Given the chaptered work "Hit Count Test"
      And all hit count information is reset
    When I go to the 1st chapter of the work "Hit Count Test"
      And I go to the 2nd chapter of the work "Hit Count Test"
      And I wait 1 second
      And the hit counts for all works are updated
      And I go to the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing a full multi-chapter work increments the hit count
    Given the chaptered work "Hit Count Test"
      And all hit count information is reset
    When I go to the work "Hit Count Test" in full mode
      And I wait 1 second
      And the hit counts for all works are updated
      And I go to the work "Hit Count Test"
    Then I should see "Hits:1"
