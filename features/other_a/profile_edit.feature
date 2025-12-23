@users
Feature: Edit profile
  In order to have a presence on the archive
  As a humble user
  I want to fill out and edit my profile

Background:
  Given the following activated user exists
    | login    | password   | email  	    |
    | editname | password   | bar@ao3.org |
    And I am logged in as "editname"
    And I want to edit my profile

Scenario: Add details
  Then I should see the page title "Edit Profile"
  When I fill in the details of my profile
  Then I should see "Your profile has been successfully updated"
    And 0 emails should be delivered
    And I should see "Test title thingy"
    And I should see "This is some text about me."

Scenario: Change details
  When I change the details in my profile
  Then I should see "Your profile has been successfully updated"
    And 0 emails should be delivered
    And I should see "Alternative title thingy"
    And I should see "This is some different text about me."

Scenario: Remove details
  When I remove details from my profile
  Then I should see "Your profile has been successfully updated"
    And 0 emails should be delivered
    And I should not see "Bio"

Scenario: Change details as an admin

  Given I am logged in as a "policy_and_abuse" admin
    And an abuse ticket ID exists
  When I go to editname profile page
    And I follow "Edit Profile"
    And I fill in "About Me" with "is it merely thy habit, to talk to dolls?"
    And I fill in "Ticket ID" with "fine"
    And I press "Update"
  Then I should see "may begin with an # and otherwise contain only numbers."
    And the field labeled "Ticket ID" should contain "fine"
  When I fill in "Ticket ID" with "480000"
    And I press "Update"
  Then I should see "Your profile has been successfully updated"
    And I should see "is it merely thy habit, to talk to dolls?"
  When I visit the last activities item
  Then I should see "edit profile"
    And I should see a link "Ticket #480000"

  # Skip logging admin activity if no change was actually made.
  When I go to editname profile page
    And I follow "Edit Profile"
    And I fill in "Ticket ID" with "480000"
    And I press "Update"
  Then I should see "Your profile has been successfully updated"
  When I go to the admin-activities page
  Then I should see 1 admin activity log entry
