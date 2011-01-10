@works
Feature: Import Works from DW
  In order to have an archive full of works
  As an author
  I want to create new works by importing them from DW
  
  Scenario: Creating a new work from an DW story with automatic metadata
    Given basic tags
      And a fandom exists with name: "Lewis", canonical: true
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://rebecca2525.dreamwidth.org/3506.html"
    When I press "Import"
    Then I should see "Preview Work"
      And I should see "Lewis" within "dd.fandom"
      And I should see "General Audiences" within "dd.rating"
      And I should see "Lewis/Hathaway" within "dd.relationship"
      And I should see "Published:2000-01-10"
      And I should see "Importing Test" within "h2.title" 
      And I should not see "[FIC]" within "h2.title" 
      And I should see "Something I made for testing purposes." within "div.summary"
      And I should see "Yes, this is really only for testing. :)" within "div.notes"
      And I should see "My first paragraph."
      And I should see "My second paragraph."
      And I should not see the "alt" text "Add to memories"
      And I should not see the "alt" text "Next Entry"
      And I should not see "location"
      And I should not see "music"
      And I should not see "mood"
      And I should not see "Entry tags"
      And I should not see "Crossposts"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I am on cosomeone's user page 
      #'
      Then I should see "Importing Test"

  Scenario: Creating a new work from an DW story that has tables
  # This is to make sure that we don't accidentally strip other tables than
  # DW metadata tables esp. when there's no DW metadata table
  
    Given basic tags
      And a fandom exists with name: "Lewis", canonical: true
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://rebecca2525.dreamwidth.org/3601.html"
    When I press "Import"
    Then I should see "Preview Work"
      And I should see "Lewis" within "dd.fandom"
      And I should see "General Audiences" within "dd.rating"
      And I should see "Lewis/Hathaway" within "dd.relationship"
      And I should see "Published:2000-01-10"
      And I should see "Importing Test" within "h2.title" 
      And I should not see "[FIC]" within "h2.title" 
      And I should see "Something I made for testing purposes." within "div.summary"
      And I should see "Yes, this is really only for testing. :)" within "div.notes"
      And I should see "My first paragraph."
      And I should see "My second paragraph."
      And I should not see the "alt" text "Add to memories"
      And I should not see the "alt" text "Next Entry"
      And I should see "My location"
      And I should see "My music"
      And I should see "My mood"
      And I should see "My tags"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I am on cosomeone's user page 
      #'
      Then I should see "Importing Test"

  
  Scenario: Creating a new work from an DW story without backdating it
    Given basic tags
      And a category exists with name: "Gen", canonical: true
      And a category exists with name: "F/M", canonical: true
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as a random user
    When I go to the import page
      And I fill in "urls" with "http://rebecca2525.dreamwidth.org/3506.html"
    When I press "Import"
    Then I should see "Preview Work"
      And I should see "Importing Test"
    When I press "Edit"
    Then I should see "* Required information"
      And I should see "Importing Test"
    When I set the publication date to today
      And I check "No Archive Warnings Apply"
    When I press "Preview"
    Then I should see "Importing Test"
    When I press "Post"
    Then I should see "Work was successfully posted."
      And I should see "Importing Test" within "h2.title" 
      And I should not see the "alt" text "Add to memories!"
      And I should not see the "alt" text "Next Entry"
  
