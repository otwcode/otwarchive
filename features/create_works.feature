@works
Feature: Create Works
  In order to have an archive full of works
  As an author
  I want to create new works

  Scenario: You can't create a work unless you're logged in
  When I go to the new work page
  Then I should see "Please log in"

  Scenario: Creating a new minimally valid work
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
    
  Scenario: Creating a new work with everything filled in
    Given a warning exists with name: "No Warnings", canonical: true
      And a category exists with name: "Gen", canonical: true
      And a category exists with name: "F/M", canonical: true
      And I am logged in as a random user
    When I go to the new work page
    Then I should see "Post New Work"
    When I select "Not Rated" from "Rating"
      And I check "No Warnings"
    Then I should see "F/M"
      And I should see "Gen"
    When I check "F/M"
      And I fill in "Fandoms" with "Supernatural"
      And I fill in "Work Title" with "All Something Breaks Loose"
      And I fill in "content" with "Bad things happen, etc."
      And I check "front-notes-options-show"
      And I fill in "work_notes" with "This is my beginning note"
      And I fill in "work_endnotes" with "This is my endingnote"
      And I fill in "Summary" with "Have a short summary"
      And I fill in "Characters" with "Sam Winchester, Dean Winchester,"
      And I fill in "Pairings" with "Harry/Ginny"
      And I press "Preview"
    Then I should see "Preview Work"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I go to the works page
    Then I should see "All Something Breaks Loose"
