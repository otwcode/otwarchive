@wip
Feature: Edit tags on a work
  In order to have an archive full of works
  As a humble user
  I want to edit the tags on one of my works

  Scenario: Edit tags on a work

  Given the following activated user exists
    | login         | password    |
    | myname        | something   |
    And a warning exists with name: "No Archive Warnings Apply", canonical: true
    And I am logged in as "myname" with password "something"
  Then I should see "Hi, myname!"
    And I should see "Log out"
  When I post the work "Test"
  Then I should see "Work was successfully posted."
    
