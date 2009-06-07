@works
Feature: Create Works
  In order to have an archive full of works
  As an author
  I want to create new works

	Scenario: You can't create a work unless you're logged in
		When I go to the new work page
		Then I should see "Please log in"

	Scenario: Creating a new valid work
		Given I am logged in as a random user
		When I go to the new work page
		And I select "Not Rated" from "Rating"
		And I select "Choose Not To Warn" from "Warning"
		And I select "Gen" from "Category"
		And I fill in "Fandoms" with "Supernatural"
		And I fill in "Add Title" with "All Hell Breaks Loose"
		And I fill in "content" with "Bad things happen, etc."
		When I press "Preview"
		Then I should see "Preview Story"
		When I press "Post"
		Then I should see "Work was successfully posted."
		When I go to the list of works
		Then I should see "All Hell Breaks Loose"
		

