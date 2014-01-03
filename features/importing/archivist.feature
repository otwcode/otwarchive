@users @admin @archivist_import
Feature: Archivist bulk imports

  Scenario: Non-archivist cannot import for others
  
  When I am logged in as a random user
    And I go to the import page
  Then I should not see "Import for others ONLY with permission"
  
  Scenario: Make a user an archivist
  
  Given I have pre-archivist setup for "elynross"
  When I am logged in as an admin
    And I make "elynross" an archivist
  Then I should see "User was successfully updated"
    
  Scenario: Archivist can see link to import for others
  
  Given I have an archivist "elynross"
    When I am logged in as "elynross"
    And I go to the import page
    Then I should see "Import for others ONLY with permission"

  Scenario: Import a single work as an archivist and send the right email
  
  Given I have an archivist "alice_ttlg"
    When I am logged in as "alice_ttlg"
      And I import the work "http://yuletidetreasure.org/archive/84/thatshall.html"
    Then I should see "We have notified the author(s) you imported stories for"
      And I should see "That Shall Achieve The Sword"
    When the system processes jobs
    Then 1 email should be delivered to "shalott@intimations.org"
      And the email should contain invitation warnings from "alice ttlg" for work "That Shall Achieve The Sword" in fandom "Merlin UK"
      
  Scenario: Import multiple works as an archivist
  
  Given I have an archivist "elynross"
    When I am logged in as "elynross"
      And I import the works "http://cesy.dreamwidth.org/154770.html, http://cesy.dreamwidth.org/394320.html"
    Then I should see multi-story import messages
      And I should see "Welcome"
      And I should see "OTW Meetup in London"
      And I should see "We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually."
   
  Scenario: Importing only sends one email even if there are many works
  
    Given I have an archivist "elynross"
    When I am logged in as "elynross"
      And I import the works "http://cesy.dreamwidth.org/154770.html, http://cesy.dreamwidth.org/394320.html"
      And the system processes jobs
    Then 1 email should be delivered to "cesy@dreamwidth.org"

  Scenario: Importing sends a different email if you're already an author on the archive

  Given the following activated user exists
    | login | email               |
    | cesy  | cesy@dreamwidth.org |
  Given I have an archivist "heathercook"
  When I am logged in as "heathercook"
    And I import the work "http://cesy.dreamwidth.org/154770.html"
  Then I should see import confirmation
    And 1 email should be delivered to "cesy@dreamwidth.org"
    And the email should contain claim information

  Scenario: Importing sends a backup email to open doors if it can't find the author

  Given I have an archivist "alice_ttlg"
    When I am logged in as "alice_ttlg"
      And I import the work "http://jennyst.dreamwidth.org/556.html"
    Then I should see import confirmation
      And I should see "Name change"
    Given the system processes jobs
    Then 1 email should be delivered to "jennyst@dreamwidth.org"
      And the email should contain invitation warnings from "alice ttlg" for work "Name change" in fandom "No Fandom"
  #    And 1 email should be delivered to "opendoors@transformativeworks.org"
  # TODO

  Scenario: Import a single work as an archivist specifying author

    Given I have an archivist "elynross"
    When I am logged in as "elynross"
      And I go to the import page
      And I import the work "http://cesy.dreamwidth.org/154770.html" by "randomtestname" with email "otwstephanie@thepotionsmaster.net"
    Then I should not see multi-story import messages
      And I should see "Welcome"
      And I should see "We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually."
    When the system processes jobs
    Then 1 email should be delivered to "otwstephanie@thepotionsmaster.net"


  Scenario: Claim a work and create a new account in response to an invite
  # TODO

  Scenario: Orphan a work in response to an invite
  # TODO

  Scenario: Refuse all further contact
  # TODO

  Scenario: Importing straight into a collection
  # TODO
