@works
Feature: Import Works
  In order to have an archive full of works
  As an author
  I want to create new works by importing them
  
  Scenario: You can't create a work unless you're logged in
  When I go to the import page
  Then I should see "Please log in"

  Scenario: Creating a new minimally valid work
    Given basic tags
      And I am logged in as a random user
    When I go to the import page
    Then I should see "Import New Work"
      And I fill in "urls" with "http://cesy.dreamwidth.org"
    When I press "Import"
    Then I should see "Preview Work"
      And I should see "Welcome"
      And I should not see "A work has already been imported from http://cesy.dreamwidth.org"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I go to the works page
    Then I should see "Recent Entries"
    
  Scenario: Creating a new work from an LJ story
    Given basic tags
      And a category exists with name: "Gen", canonical: true
      And a category exists with name: "F/M", canonical: true
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://cesy.dreamwidth.org/394320.html"
    When I press "Import"
    Then I should see "Preview Work"
      And I should see "OTW Meetup"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I am on cosomeone's user page
    Then I should see "OTW Meetup"
      And I should not see "Rambling musings"
      And I should not see "Search" within "#main"

  Scenario: Creating a new work from an LJ story without backdating it
    Given basic tags
      And a category exists with name: "Gen", canonical: true
      And a category exists with name: "F/M", canonical: true
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as a random user
    When I go to the import page
      And I fill in "urls" with "http://cesy.dreamwidth.org/394320.html"
    When I press "Import"
    Then I should see "Preview Work"
      And I should see "OTW Meetup"
    When I press "Edit"
    Then I should see "* Required information"
      And I should see "OTW Meetup"
    When I set the publication date to today
      And I check "No Archive Warnings Apply"
    When I press "Preview"
    Then I should see "OTW Meetup"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I go to the works page
    Then I should see "OTW Meetup"
      And I should not see "Rambling musings"
      And I should not see "Profile" within "#main"

  Scenario: Creating a new work from a Yuletide story
    Given basic tags
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as a random user
    When I go to the import page
      And I fill in "urls" with "http://yuletidetreasure.org/archive/79/littlemiss.html"
    When I press "Import"
    Then I should see "Preview Work"
      And I should see "Little Miss Curious"
    When I press "Post"
    Then I should see "Work was successfully posted."
      And I should see "Little Miss Sunshine" within "dd"
      And I should see "Yule Madness Treat, unbetaed." within "div"
      And I should not see "Search Engine"