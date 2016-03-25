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
    And I import the works "http://ao3testing.dreamwidth.org/593.html, http://ao3testing.dreamwidth.org/325.html"
  Then I should see multi-story import messages
    And I should see "Story"
    And I should see "Test entry"
    And I should see "We have notified the author(s) you imported works for. If any were missed, you can also add co-authors manually."
   
  Scenario: Importing only sends one email even if there are many works
  
    Given I have an archivist "elynross"
      And the default ratings exist
    When I am logged in as "elynross"
      And I import the works "http://ao3testing.dreamwidth.org/593.html, http://ao3testing.dreamwidth.org/325.html"
      And the system processes jobs
    Then 1 email should be delivered to "ao3testing@dreamwidth.org"

  Scenario: Importing sends a different email if you're already an author on the archive

  Given the following activated user exists
    | login | email                     |
    | ao3   | ao3testing@dreamwidth.org |
    And I have an archivist "heathercook"
    And the default ratings exist
  When I am logged in as "heathercook"
    And I import the work "http://ao3testing.dreamwidth.org/593.html"
  Then I should see import confirmation
    And 1 email should be delivered to "ao3testing@dreamwidth.org"
    And the email should contain claim information

  Scenario: Importing sends an email to a guessed address if it can't find the author

  Given I have an archivist "alice_ttlg"
    And the default ratings exist
  When I am logged in as "alice_ttlg"
    And I import the work "http://ao3testing.dreamwidth.org/593.html"
  Then I should see import confirmation
    And I should see "Story"
  When the system processes jobs
  # Importer assumes dreamwidth email for works from there
  Then 1 email should be delivered to "ao3testing@dreamwidth.org"
    And the email should contain invitation warnings from "alice ttlg" for work "Story" in fandom "Testing"

  Scenario: Import a single work as an archivist specifying author

    Given I have an archivist "elynross"
      And the default ratings exist
    When I am logged in as "elynross"
      And I go to the import page
      And I import the work "http://ao3testing.dreamwidth.org/593.html" by "randomtestname" with email "otwstephanie@example.com"
    Then I should not see multi-story import messages
      And I should see "Story"
      And I should see "randomtestname"
      And I should see "We have notified the author(s) you imported works for. If any were missed, you can also add co-authors manually."
    When the system processes jobs
    Then 1 email should be delivered to "otwstephanie@example.com"

  Scenario: Import a single work as an archivist specifying an external author with an invalid name

    Given I have an archivist "elynross"
      And the default ratings exist
    When I am logged in as "elynross"
      And I go to the import page
      And I import the work "http://ao3testing.dreamwidth.org/593.html" by "ra_ndo!m-t??est n@me." with email "otwstephanie@example.com"
    Then I should see import confirmation
      And I should see "ra_ndom-test n@me."
    When the system processes jobs
      Then 1 email should be delivered to "otwstephanie@example.com"

  Scenario: Claim a work and create a new account in response to an invite

    Given I have an archivist "elynross"
      And the default ratings exist
      And account creation is enabled
    When I am logged in as "elynross"
      And I go to the import page
      And I import the work "http://ao3testing.dreamwidth.org/593.html" by "randomtestname" with email "otwstephanie@example.com"
      And the system processes jobs
    Then 1 email should be delivered to "otwstephanie@example.com"
      And the email should contain "Claim or remove your works"
    When I am logged out
      And I follow "Claim or remove your works" in the email
    Then I should see "Claiming Your Imported Works"
      And I should see "An archive including some of your work(s) has been moved to the Archive of Our Own. Please let us know what you'd like us to do with them."
    When I press "Sign me up and give me my works! Yay!"
    Then I should see "Create Account"
    When I fill in the sign up form with valid data
      And I press "Create Account"
    Then I should see "Account Created!"

  Scenario: Orphan a work in response to an invite, leaving name on it

    Given I have an archivist "elynross"
      And the default ratings exist
      And I have an orphan account
    When I am logged in as "elynross"
      And I go to the import page
      And I import the work "http://ao3testing.dreamwidth.org/593.html" by "randomtestname" with email "otwstephanie@example.com"
      And the system processes jobs
    Then 1 email should be delivered to "otwstephanie@example.com"
      And the email should contain "Claim or remove your works"
    When I am logged out
      And I follow "Claim or remove your works" in the email
    Then I should see "Claiming Your Imported Works"
      And I should see "An archive including some of your work(s) has been moved to the Archive of Our Own. Please let us know what you'd like us to do with them."
    When I choose "imported_stories_orphan"
      And I press "Update"
    Then I should see "Your imported stories have been orphaned. Thank you for leaving them in the archive! Your preferences have been saved."
    When I am logged in
      And I view the work "Story"
    Then I should see "randomtestname"
      And I should see "orphan_account"

  Scenario: Orphan a work in response to an invite, taking name off it

    Given I have an archivist "elynross"
      And the default ratings exist
      And I have an orphan account
    When I am logged in as "elynross"
      And I go to the import page
      And I import the work "http://ao3testing.dreamwidth.org/593.html" by "randomtestname" with email "otwstephanie@example.com"
      And the system processes jobs
    Then 1 email should be delivered to "otwstephanie@example.com"
      And the email should contain "Claim or remove your works"
    When I am logged out
      And I follow "Claim or remove your works" in the email
    Then I should see "Claiming Your Imported Works"
      And I should see "An archive including some of your work(s) has been moved to the Archive of Our Own. Please let us know what you'd like us to do with them."
    When I choose "imported_stories_orphan"
      And I check "remove_pseud"
      And I press "Update"
    Then I should see "Your imported stories have been orphaned. Thank you for leaving them in the archive! Your preferences have been saved."
    When I am logged in
      And I view the work "Story"
    Then I should not see "randomtestname"
      And I should see "orphan_account"

  Scenario: Refuse all further contact

    Given I have an archivist "elynross"
      And the default ratings exist
    When I am logged in as "elynross"
      And I go to the import page
      And I import the work "http://ao3testing.dreamwidth.org/593.html" by "randomtestname" with email "otwstephanie@example.com"
      And the system processes jobs
    Then 1 email should be delivered to "otwstephanie@example.com"
      And the email should contain "Claim or remove your works"
    When I am logged out
      And I follow "Claim or remove your works" in the email
    Then I should see "Claiming Your Imported Works"
      And I should see "An archive including some of your work(s) has been moved to the Archive of Our Own. Please let us know what you'd like us to do with them."
    When I choose "imported_stories_delete"
      And I check "external_author_do_not_email"
      And I press "Update"
    Then I should see "Your imported stories have been deleted. Your preferences have been saved."

  Scenario: Importing straight into a collection

    Given I have an archivist "elynross"
      And the default ratings exist
      And I have a collection "Club"
    When I am logged in as "elynross"
      And I go to the import page
      And I start to import the work "http://ao3testing.dreamwidth.org/593.html" by "randomtestname" with email "otwstephanie@example.com"
      And I press "Import"
    Then I should see "We have notified the author(s) you imported works for. If any were missed, you can also add co-authors manually."
    When I press "Edit"
      And I fill in "work_collection_names" with "Club"
      And I press "Post Without Preview"
    Then I should see "Story"
      And I should see "randomtestname"
      And I should see "Club"
    When the system processes jobs
    Then 1 email should be delivered to "otwstephanie@example.com"

  Scenario: Should not be able to import for others unless the box is checked
  
    Given I have an archivist "elynross"
      And the default ratings exist
    When I am logged in as "elynross"
      And I go to the import page
      And I fill in "URLs*" with "http://ao3testing.dreamwidth.org/593.html"
      And I fill in "Author Name*" with "ao3testing"
      And I fill in "Author Email Address*" with "ao3testing@example.com"
    When I press "Import"
    Then I should see /You have entered an external author name or e-mail address but did not select "Import for others."/
    When I check the 1st checkbox with id matching "importing_for_others"
    And I press "Import"
    Then I should see "We have notified the author(s) you imported works for. If any were missed, you can also add co-authors manually."

  Scenario: Archivist can't see Open Doors tools, OD committee can

  Given I have an archivist "elynross"
    And I have an Open Doors committee member "Ariana"
  When I am logged in as "elynross"
    And I go to the Open Doors tools page
  Then I should see "Sorry, you don't have permission to access the page you were trying to reach."
  When I am logged in as "Ariana"
    And I go to the Open Doors tools page
  Then I should see "Update Redirect URL"
