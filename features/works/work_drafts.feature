@works @search
@no-txn
Feature: Work Drafts

  Scenario: Creating a work draft
  Given I am logged in as "Scott" with password "password"
  When the draft "scotts draft"
    And I press "Cancel"
  Then I should see "The work was not posted. It will be saved here in your drafts for one month, then deleted from the Archive."

  Scenario: Creating an draft Chapter on a draft Work
  Given I am logged in as "Scott" with password "password"
    And the draft "scotts other draft"
    And I press "Cancel"
    And I edit the work "scotts other draft"
    And I follow "Add Chapter"
    And I fill in "content" with "this is second chapter content"
    And I press "Preview"
  Then I should see "This is a draft showing what this chapter will look like when it's posted to the Archive. You should probably read the whole thing to check for problems before posting. The chapter draft will be stored until you post or discard it, or until its parent work is deleted (unposted work drafts are automatically deleted one week after creation; this chapter's work is scheduled for deletion at"



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
      And I press "Search"
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
