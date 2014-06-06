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
    And I should not see "Save Without Posting"
  When I fill in "Fandoms" with "Stargate SG-1, Hana Yori Dango"
    And I fill in "Additional Tags" with "Alternate Universe"
    And I press "Post Without Preview"
  Then I should see "Stargate SG-1"
    And I should see "Hana Yori Dango"
    And I should see "Alternate Universe"
    And I should see "Work was successfully updated"
  
  Scenario: Edit tags on a draft
  Given I am logged in as "imit" with password "tagyoure"
    And the draft "Freeze Tag"
  When I am on imit's works page
  Then I should see "Drafts (1)"
  When I follow "Drafts (1)"
  Then I should see "Freeze Tag"
    And I should see "Edit Tags" within "#main .own.work.blurb .navigation"
  When I follow "Edit Tags"
    Then I should see "Edit Work Tags"
  When I fill in "Fandoms" with "Games, Anthropomorphic"
    And I fill in "Additional Tags" with "The cooler version of tag"
    And I press "Save Without Posting"
  Then I should see "Tags were successfully updated"
    And I should see "This work is a draft and has not been posted"
    And I should see "Games"
    And I should see "Anthropomorphic"
    And I should see "The cooler version of tag"
 
  Scenario: Ampersands and angle brackets should display in work titles on Edit Tags page
  Given I have loaded the fixtures
    And I am logged in as "testuser2" with password "testuser2"
  When I view the work "I am &lt;strong&gt;er Than Yesterday &amp; Other Lies"
    And I follow "Edit Tags"
  Then I should see "I am <strong>er Than Yesterday & Other Lies"