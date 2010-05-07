@works
Feature: Edit Works
  In order to have an archive full of works
  As an author
  I want to edit existing works

	Scenario: You can't edit a work unless you're logged in
		When I view the work "First work"
    Then I should not see "Edit"
    
  Scenario: You can't edit a work unless you're the author
    Given I am logged in as "testuser" with password "test"
		When I view the work "fourth"
		Then I should not see "Edit"  

	Scenario: Editing a valid work
    When I am on the homepage
    Then I should see "Sign Up"
    When I am logged in as a random user
		And I go to the new work page
		And I select "Not Rated" from "Rating"
		And I check "No Warnings"
		And I fill in "Fandoms" with "Supernatural"
		And I fill in "Work Title" with "Editing"
		And I fill in "content" with "Bad things happen, etc."
		When I press "Preview"
		Then I should see "Preview Work"
    And I should see "Fandom: Supernatural"
    And I should see "Editing"
		When I press "Post"
		Then I should see "Work was successfully posted."
		When I go to the list of works
		Then I should see "Editing"
		When I edit the work "Editing"
    Then I should see "Edit Work"
		When I fill in "work_freeform" with "Alternate Universe"
		And I press "Preview"
		Then I should see "Preview Work"
    And I should see "Fandom: Supernatural"
    And I should see "Additional Tags: Alternate Universe"
		When I press "Update"
		Then I should see "Work was successfully updated."
		When I go to the list of works
		Then I should see work "Editing" with tags "Alternate Universe & Supernatural"
		

