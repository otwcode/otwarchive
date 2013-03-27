@tags @works
Feature: Edit tags on a work
  In order to have an archive full of works
  As a humble user
  I want to edit the tags on one of my works

  Scenario: Edit tags on a work

  Given the following activated user exists
    | login         | password    |
    | myname        | something   |
    And I am logged in as "myname" with password "something"
  Then I should see "Hi, myname!"
    And I should see "Log Out"
  When I post the work "Testerwork"
  Then I should see "Work was successfully posted."
    And I should see "Stargate SG-1"
    And I should not see "Hana Yori Dango"
    And I should not see "Alternate Universe"
  When I follow "myname"
  Then I should see "Testerwork"
    And I should see "Edit Tags"
  When I follow "Edit Tags"
  Then I should see "Edit Work Tags for "
    And I should see "Testerwork"
  When I fill in "Fandoms" with "Stargate SG-1, Hana Yori Dango"
    And I fill in "Additional Tags" with "Alternate Universe"
    And I press "Post Without Preview"
  Then I should see "Stargate SG-1"
    And I should see "Hana Yori Dango"
    And I should see "Alternate Universe"
    And I should see "Work was successfully updated"
  
