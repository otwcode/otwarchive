@works
Feature: Edit Works
  In order to have an archive full of works
  As an author
  I want to edit existing works

  Scenario: You can't edit a work unless you're logged in and it's your work
    Given I have loaded the fixtures
    When I view the work "First work"
    Then I should not see "Edit"
    Given I am logged in as "testuser" with password "testuser"
    When I view the work "fourth"
    Then I should not see "Edit"  
    When I am on testuser's works page
    Then I should see "Edit"
      And I follow "First work"
    Then I should see "first fandom" 
      And I should not see "new tag"
      And I should see "Edit"
    When I follow "Edit"
    Then I should see "Edit Work"
    When I fill in "work_freeform" with "new tag"
      And I press "Preview"
    Then I should see "Preview Work"
      And I should see "Fandom: first fandom"
      And I should see "Additional Tags: new tag"
    When I press "Update"
    Then I should see "Work was successfully updated."
    When I go to testuser's works page
    Then I should see work "First work" with tags "first fandom & new tag"
