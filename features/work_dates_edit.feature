@works
Feature: Edit Works Dates
  In order to have an archive full of works
  As an author
  I want to edit existing works

  Scenario: Editing dates on a work
  
    Given I have loaded the fixtures
    Given I am logged in as "testuser" with password "testuser"
    When I am on testuser's works page
    Then I should not see "less than 1 minute ago"
      And I should see "29 Apr 2010"
    When I follow "First work"
    Then I should see "first fandom" 
      And I should see "Published:2010-04-30"
      And I should see "Edit"
    When I follow "Edit"
    Then I should see "Edit Work"
    When I fill in "content" with "first chapter content"
      And I check "chapters-options-show"
      And I fill in "work_wip_length" with "3"
      And I press "Preview"
    Then I should see "Preview Work"
      And I should see "Fandom: first fandom"
      And I should see "first chapter content"
      And I should see "Published:2010-04-30"
    When I press "Update"
    Then I should see "Work was successfully updated."
      And I should see "Published:2010-04-30"
    When I follow "Add Chapter"
      And I fill in "content" with "this is my second chapter"
      And I press "Preview"
    Then I should see "This is a preview of what this chapter will look like"
    When I follow "Post Chapter"
    Then I should see "Chapter has been posted"
      And I should see "Published:2010-04-30"
      And I should see Updated today
    When I am on testuser's works page
    Then I should see "less than 1 minute ago"
      And I should not see "29 Apr 2010"
