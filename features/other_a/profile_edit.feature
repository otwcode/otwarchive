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
    And I should see "I live in"

Scenario: Change details

  When I change the details in my profile
  Then I should see "Your profile has been successfully updated"
    And 0 emails should be delivered
    And I should see "I live in"

Scenario: Remove details

  When I remove details from my profile
  Then I should see "Your profile has been successfully updated"
    And 0 emails should be delivered
    And I should not see "I live in"

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

Scenario: Changing email address shows a confirmation page and sends a confirmation mail

  When it is currently 2020-04-10 13:37
    And the email address change confirmation period is set to 4 days
    And I change my preferences to display my email address
    And I follow "Edit My Profile"
    And I follow "Change Email"
    And I fill in "New email" with "valid2@archiveofourown.org"
    And I fill in "Enter new email again" with "valid2@archiveofourown.org"
    And I fill in "Password" with "password"
    And I press "Confirm New Email"
  Then I should see "Are you sure you want to change your email address to valid2@archiveofourown.org?"
    And I should see "If you don't confirm your request within 4 days"
    And 0 emails should be delivered
  When I press "Yes, Change Email"
  Then I should see "You have requested to change your email address to valid2@archiveofourown.org."
    And I should see "If you don't confirm your request by April 14, 2020"
    And I should see "bar@ao3.org"
    And 1 email should be delivered to "bar@ao3.org"
    And the email should contain "Someone has made a request to change the email address associated with your AO3 account."
    And the email should contain "valid2@archiveofourown.org"
    And 1 email should be delivered to "valid2@archiveofourown.org"
    And the email should contain "request to change the email address associated with the AO3 account"
    And the email should contain "editname"

  When I am a visitor
    And I follow "confirm your email change" in the email
  Then I should see "Sorry, you don't have permission to access the page you were trying to reach. Please log in."
  When I go to editname's profile page
  Then I should see "My email address: bar@ao3.org"

  When I am logged in as "editname"
    And I follow "confirm your email change" in the email
  Then I should see "Your email has been successfully updated."
    And I should see "valid2@archiveofourown.org"
    But I should not see "bar@ao3.org"
    But I should not see "You have requested to change your email address"
  When I go to editname's profile page
  Then I should see "My email address: valid2@archiveofourown.org"
  When I log out
    And I go to editname's profile page
  Then I should see "My email address: valid2@archiveofourown.org"

Scenario: Changing email address -- canceling in confirmation step

  When I follow "Change Email"
    And I start to change my email to "valid2@archiveofourown.org"
  Then I should see "Are you sure you want to change your email address"
    And 0 emails should be delivered
  When I follow "Cancel"
  Then I should see "Change Email" within "h2.heading"
    And 0 emails should be delivered
    And I should not see "You have requested to change your email address"

Scenario: Changing email address -- request expires

  When it is currently 2020-04-10 13:37
    And the email address change confirmation period is set to 4 days
    And I follow "Change Email"
    And I request to change my email to "valid2@archiveofourown.org"
  Then I should see "If you don't confirm your request by April 14, 2020"
    And 1 email should be delivered to "valid2@archiveofourown.org"
    And the email should contain "request to change the email address"
    And I should see "You have requested to change your email address"

  When it is currently 2020-04-15 14:00
    And I follow "My Preferences"
    And I follow "Change Email"
  Then I should not see "You have requested to change your email address"
    And I should see "bar@ao3.org"
    But I should not see "valid2@archiveofourown.org"
  When I follow "confirm your email change" in the email
  Then I should see "This email confirmation link is invalid or expired. Please check your email for the correct link or submit the email change form again."
    And I should see "bar@ao3.org"
    But I should not see "valid2@archiveofourown.org"

Scenario: Changing email address -- resubmitting form changes target email and expiration date

  When it is currently 2020-04-10 13:37
    And the email address change confirmation period is set to 4 days
    And I follow "Change Email"
    And I request to change my email to "valid2@archiveofourown.org"
  Then I should see "If you don't confirm your request by April 14, 2020"
    And 1 email should be delivered to "bar@ao3.org"
    And 1 email should be delivered to "valid2@archiveofourown.org"
    And the email should contain "request to change the email address"

  When it is currently 2020-04-12 14:00
    And I request to change my email to "another@archiveofourown.org"
  Then I should see "You have requested to change your email address to another@archiveofourown.org."
    And I should see "If you don't confirm your request by April 16, 2020"
    # The original email gets another notification
    And 2 emails should be delivered to "bar@ao3.org"
    # Old link should be invalid
    And 1 email should be delivered to "valid2@archiveofourown.org"
  When I follow "confirm your email change" in the email
  Then I should see "This email confirmation link is invalid or expired. Please check your email for the correct link or submit the email change form again."
    And I should see "bar@ao3.org"
    And I should see "You have requested to change your email address to another@archiveofourown.org"
    But I should not see "valid2@archiveofourown.org"
    # Newest email gets new link that should work
    And 1 email should be delivered to "another@archiveofourown.org"
    And the email should contain "request to change the email address"
  When I follow "confirm your email change" in the email
  Then I should see "Your email has been successfully updated."
    And I should see "another@archiveofourown.org"
    But I should not see "valid2@archiveofourown.org"
    But I should not see "bar@ao3.org"

Scenario: Changing email address -- after requesting password reset

  When I am logged out
    And I follow "Forgot password?"
    And I fill in "Email address or username" with "editname"
    And I press "Reset Password"
  Then 1 email should be delivered to "bar@ao3.org"
  When all emails have been delivered
    And I am logged in as "editname"
    And I follow "My Preferences"
    And I follow "Change Email"
    And I request to change my email to "valid2@archiveofourown.org"
  Then I should see "You have requested to change your email address to valid2@archiveofourown.org."
    And 1 email should be delivered to "bar@ao3.org"
    And 1 email should be delivered to "valid2@archiveofourown.org"
  When I follow "confirm your email change" in the email
  Then I should see "Your email has been successfully updated."
    And I should see "valid2@archiveofourown.org"
    But I should not see "bar@ao3.org"

Scenario: Changing email address -- translated emails are sent when user enables locale settings
    Given a locale with translated emails
      And the user "editname" enables translated emails
      And all emails have been delivered
    When I am logged in as "editname"
      And I follow "My Preferences"
      And I follow "Change Email"
      And I request to change my email to "valid2@archiveofourown.org"
    Then the email address "bar@ao3.org" should be emailed
      And the email should have "Email change request" in the subject
      And the email to email address "bar@ao3.org" should be translated
      And 1 email should be delivered to "valid2@archiveofourown.org"
      And the email should have "Confirm your email change" in the subject
      And the email to email address "valid2@archiveofourown.org" should be translated

Scenario: Date of birth - under age

  When I enter a birthdate that shows I am under age
  Then I should see "You must be over 13"

Scenario: Entering date of birth and displaying

  When I fill in my date of birth
  Then I should see "Your profile has been successfully updated"
  When I change my preferences to display my date of birth
  Then I should see "My birthday: 1980-11-30"
    And 0 emails should be delivered
  When I log out
    And I go to editname's profile page
  Then I should see "My birthday: 1980-11-30"

Scenario: Change password - mistake in typing old password

  When I make a mistake typing my old password
  Then I should see "Your old password was incorrect"

Scenario: Change password - mistake in typing new password confirmation

  When I make a typing mistake confirming my new password
  Then I should see "Password confirmation doesn't match new password."

Scenario: Change password

  When I change my password
  Then I should see "Your password has been changed. To protect your account, you have been logged out of all active sessions. Please log in with your new password."
    And 0 emails should be delivered
