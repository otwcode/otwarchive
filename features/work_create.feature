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
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as a random user
    When I go to testuser's user page
      And I follow "Profile"
    Then I should see "About"
    When I follow "Manage my pseuds"
    Then I should see "Pseuds for"
    When I follow "New Pseud"
    Then I should see "New pseud"
    When I fill in "Name" with "Pseud2"
      And I press "Create"
    Then I should see "Pseud was successfully created."
    When I follow "Back To Pseuds"
      And I follow "New Pseud"
      And I fill in "Name" with "Pseud3"
      And I press "Create"
    Then I should see "Pseud was successfully created."
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
      And I fill in "Recipient" with "Someone else"
      And I select "Pseud2" from "work_author_attributes_ids_"
      And I select "Pseud3" from "work_author_attributes_ids_"
      And I press "Preview"
    Then I should see "Preview Work"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I go to the works page
    Then I should see "All Something Breaks Loose"
    When I follow "All Something Breaks Loose"
    Then I should see "All Something Breaks Loose"
      And I should see "Fandom: Supernatural"
      And I should see "Rating: Not Rated"
      And I should see "Archive Warning: No Warnings"
      And I should see "Category: F/M"
      And I should see "Characters: Sam Winchester, Dean Winchester"
      And I should see "Pairing: Harry/Ginny"
      And I should see "For Someone else"
      And I should see "Notes"
      And I should see "This is my beginning note"
      And I should see "See the end of the work for more notes"
      And I should see "This is my endingnote"
      And I should see "Summary"
      And I should see "Have a short summary"
      And I should see "Pseud2" within ".byline"
      And I should see "Pseud3" within ".byline"
      And I should see "Bad things happen, etc."
    When I follow "Add chapter"
      And I fill in "Chapter Title" with "This is my second chapter"
      And I fill in "content" with "Let's write another story"
      And I press "Preview"
      And I press "Post"
    Then I should see "All Something Breaks Loose"
      And I should see "Chapter 1"
      And I should see "Bad things happen, etc."
      And I should not see "Let's write another story"
    When I follow "Next Chapter"
    Then I should see "Chapter 2 : This is my second chapter"
      And I should see "Let's write another story"
      And I should not see "Bad things happen, etc."
    When I follow "View Entire Work"
    Then I should see "Bad things happen, etc."
      And I should see "Let's write another story"
    When I follow "Edit"
      And I check "co-authors-options-show"
      And I fill in "pseud_byline" with "Does_not_exist"
      And I press "Preview"
    Then I should see "Please verify the names of your co-authors"
      And I should see "These pseuds are invalid: Does_not_exist"
    When I fill in "pseud_byline" with "cosomeone"
      And I press "Preview"
      And I press "Update"
    Then I should see "Work was successfully updated"
      And I should see "cosomeone" within ".byline"
      And I should see "Pseud2" within ".byline"
      And I should see "Pseud3" within ".byline"
