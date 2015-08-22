@users @admin @archivist_import
Feature: Archivist bulk imports

  Scenario: Non-archivist cannot import for others
  
  Given I am logged in as a random user
    And the default ratings exist
  When I go to the import page
  Then I should not see "Import for others ONLY with permission"
  
  Scenario: Make a user an archivist
  
  Given I have pre-archivist setup for "elynross"
    And the default ratings exist
  When I am logged in as an admin
    And I make "elynross" an archivist
  Then I should see "User was successfully updated"
    
  Scenario: Archivist can see link to import for others
  
  Given I have an archivist "elynross"
    And the default ratings exist
  When I am logged in as "elynross"
    And I go to the import page
  Then I should see "Import for others ONLY with permission"

  Scenario: Import a single work as an archivist and send the right email
  
  Given I have an archivist "alice_ttlg"
    And the default ratings exist
  When I am logged in as "alice_ttlg"
    And I import the work "http://rebecca2525.livejournal.com/3562.html"
  Then I should see "We have notified the author(s) you imported works for"
    And I should see "Importing Test"
  When the system processes jobs
  Then 1 email should be delivered to "rebecca2525@livejournal.com"
    And the email should contain invitation warnings from "alice ttlg" for work "Importing Test" in fandom "Lewis"
      
  Scenario: Import multiple works as an archivist
  
  Given I have an archivist "elynross"
    And the default ratings exist
  When I am logged in as "elynross"
    And I import the works "http://cesy.dreamwidth.org/154770.html, http://cesy.dreamwidth.org/394320.html"
  Then I should see multi-story import messages
    And I should see "Welcome"
    And I should see "OTW Meetup in London"
    And I should see "We have notified the author(s) you imported works for. If any were missed, you can also add co-authors manually."
   
  Scenario: Importing only sends one email even if there are many works
  
    Given I have an archivist "elynross"
      And the default ratings exist
    When I am logged in as "elynross"
      And I import the works "http://cesy.dreamwidth.org/154770.html, http://cesy.dreamwidth.org/394320.html"
      And the system processes jobs
    Then 1 email should be delivered to "cesy@dreamwidth.org"

  Scenario: Importing sends a different email if you're already an author on the archive

  Given the following activated user exists
    | login | email               |
    | cesy  | cesy@dreamwidth.org |
    And I have an archivist "heathercook"
    And the default ratings exist
  When I am logged in as "heathercook"
    And I import the work "http://cesy.dreamwidth.org/154770.html"
  Then I should see import confirmation
    And 1 email should be delivered to "cesy@dreamwidth.org"
    And the email should contain claim information

  Scenario: Importing sends a backup email to open doors if it can't find the author

  Given I have an archivist "alice_ttlg"
    And the default ratings exist
  When I am logged in as "alice_ttlg"
    And I import the work "http://jennyst.dreamwidth.org/556.html"
  Then I should see import confirmation
    And I should see "Name change"
  When the system processes jobs
  Then 1 email should be delivered to "jennyst@dreamwidth.org"
    And the email should contain invitation warnings from "alice ttlg" for work "Name change" in fandom "No Fandom"
  # And 1 email should be delivered to "opendoors@transformativeworks.org"
  # TODO

  Scenario: Import a single work as an archivist specifying author

    Given I have an archivist "elynross"
      And the default ratings exist
    When I am logged in as "elynross"
      And I go to the import page
      And I import the work "http://cesy.dreamwidth.org/154770.html" by "randomtestname" with email "otwstephanie@thepotionsmaster.net"
    Then I should not see multi-story import messages
      And I should see "Welcome"
      And I should see "randomtestname"
      And I should see "We have notified the author(s) you imported works for. If any were missed, you can also add co-authors manually."
    When the system processes jobs
    Then 1 email should be delivered to "otwstephanie@thepotionsmaster.net"

  Scenario: Import a single work as an archivist specifying an external author with an invalid name

    Given I have an archivist "elynross"
      And the default ratings exist
    When I am logged in as "elynross"
      And I go to the import page
      And I import the work "http://cesy.dreamwidth.org/154770.html" by "ra_ndo!m-t??est n@me." with email "otwstephanie@thepotionsmaster.net"
    Then I should see import confirmation
      And I should see "ra_ndom-test n@me."
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
  
  Scenario: Should not be able to import for others unless the box is checked
  
    Given I have an archivist "elynross"
      And the default ratings exist
    When I am logged in as "elynross"
      And I go to the import page
      And I fill in "URLs*" with "http://cesy.dreamwidth.org/154770.html"
      And I fill in "Author Name*" with "cesy"
      And I fill in "Author Email Address*" with "cesy@dreamwidth.org"
    When I press "Import"
    Then I should see /You have entered an external author name or e-mail address but did not select "Import for others."/
    When I check the 1st checkbox with id matching "importing_for_others"
    And I press "Import"
    Then I should see "We have notified the author(s) you imported works for. If any were missed, you can also add co-authors manually."
