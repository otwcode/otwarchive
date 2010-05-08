@works
Feature: Create Works
  In order to have an archive full of works
  As an author
  I want to create new works

  Scenario: You can't create a work unless you're logged in
  When I go to the new work page
  Then I should see "Please log in"

  Scenario: Creating a new valid work
    Given a warning exists with name: "No Warnings", canonical: true
      And I am logged in as a random user
    When I go to the new work page
    Then I should see "Post New Work"
      And I select "Not Rated" from "Rating"
      And I check "No Warnings"
      And I fill in "Fandoms" with "Supernatural"
      And I fill in "Work Title" with "All Hell Breaks Loose"
      And I fill in "content" with "Bad things happen, etc."
    When I press "Preview"
    Then I should see "Preview Work"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I go to the works page
    Then I should see "All Hell Breaks Loose"
