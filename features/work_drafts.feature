@works @search
@no-txn
Feature: Work Drafts

  Scenario: Purging old drafts
  Given I am logged in as "drafter" with password "something"
    When the work "old draft work" was created 8 days ago
    And the work "new draft work" was created 2 days ago
    When I am on drafter's works page
    Then I should see "Drafts (2)"
    When the purge_old_drafts rake task is run
      And I reload the page
    Then I should see "Drafts (1)"
    
  Scenario: Drafts cannot be found by search
  Given I am logged in as "drafter" with password "something"
    And the draft "draft to post" 
  Given the work indexes are updated
    When I fill in "site_search" with "draft"
      And I press "search"
    Then I should see "No results found"

  Scenario: Posting drafts from drafts page
    Given I am logged in as "drafter" with password "something"
      And the draft "draft to post" 
    When I am on drafter's works page
    Then I should see "Drafts (1)"
    When I follow "Drafts (1)"
    Then I should see "draft to post"
      And I should see "Post Draft" within "#main .own.work.blurb .navigation"
      And I should see "Delete Draft" within "#main .own.work.blurb .navigation"
    When I follow "Post Draft"
    Then I should see "draft to post"
      And I should see "drafter"
      And I should not see "Preview"
      
    Scenario: Deleting drafts from drafts page
      Given I am logged in as "drafter" with password "something"
        And the draft "draft to delete" 
      When I am on drafter's works page
      Then I should see "Drafts (1)"
      When I follow "Drafts (1)"
      Then I should see "draft to delete"
        And I should see "Post Draft" within "#main .own.work.blurb .navigation"
        And I should see "Delete Draft" within "#main .own.work.blurb .navigation"
      When I follow "Delete Draft"
      Then I should see "Drafts (0)"
        And I should see "Your work draft to delete was deleted"
