@works
Feature: Work Drafts

  Scenario: Purging old drafts
    And I am logged in as "drafter" with password "something"
    When the work "old draft work" was created 8 days ago
    And the work "new draft work" was created 2 days ago
    When I am on drafter's works page
    Then I should see "My Drafts (2)"
    When the purge_old_drafts rake task is run
      And I reload the page
    Then I should see "My Drafts (1)"
