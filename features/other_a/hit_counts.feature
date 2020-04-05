@javascript
Feature: Hit Counts
  Scenario: When the owner views their own work, it doesn't increment the hit count
    Given I have a work "Hit Count Test"
    When I view the work "Hit Count Test"
      And the hit counts for all works are updated
      And I view the work "Hit Count Test"
    Then I should see "Hits:0"

  Scenario: Viewing a work logged-in increments the hit count
    Given I have a work "Hit Count Test"
      And I am logged in as "viewer"
    When I view the work "Hit Count Test"
      And the hit counts for all works are updated
      And I view the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing a work logged-out increments the hit count
    Given I have a work "Hit Count Test"
      And I am logged out
    When I view the work "Hit Count Test"
      And the hit counts for all works are updated
      And I view the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing the first chapter logged-in increments the hit count
    Given the chaptered work "Hit Count Test"
      And I am logged in as "viewer"
    When I view the 1st chapter of the work "Hit Count Test"
      And the hit counts for all works are updated
      And I view the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing the first chapter logged-out increments the hit count
    Given the chaptered work "Hit Count Test"
      And I am logged out
    When I view the 1st chapter of the work "Hit Count Test"
      And the hit counts for all works are updated
      And I view the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing the second chapter logged-in increments the hit count
    Given the chaptered work "Hit Count Test"
      And I am logged in as "viewer"
    When I view the 2nd chapter of the work "Hit Count Test"
      And the hit counts for all works are updated
      And I view the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing the second chapter logged-out increments the hit count
    Given the chaptered work "Hit Count Test"
      And I am logged out
    When I view the 2nd chapter of the work "Hit Count Test"
      And the hit counts for all works are updated
      And I view the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing multiple chapters in sequence only increments the hit count once
    Given the chaptered work "Hit Count Test"
    When I view the 1st chapter of the work "Hit Count Test"
      And I view the 2nd chapter of the work "Hit Count Test"
      And the hit counts for all works are updated
      And I view the work "Hit Count Test"
    Then I should see "Hits:1"

  Scenario: Viewing an unrevealed work doesn't increment the hit count
    Given the hidden collection "UnrevealedDrafts"
      And I am logged in as "creator"
      And I post the work "Hit Count Test" in collection "UnrevealedDrafts"
      And I am logged in as "moderator"
    When I view the work "Hit Count Test"
      And the hit counts for all works are updated
      And I view the work "Hit Count Test"
    Then I should see "Hits:0"

  Scenario: Viewing a work hidden by an admin doesn't increment the hit count
    Given the spam work "Hit Count Test"
      And I am logged in as an admin
    When I view the work "Hit Count Test"
      And the hit counts for all works are updated
      And I view the work "Hit Count Test"
    Then I should see "Hits:0"
