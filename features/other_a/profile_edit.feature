@users
Feature: Edit profile
  In order to have a presence on the archive
  As a humble user
  I want to fill out and edit my profile

Background:
  Given the following activated user exists
	| login    | password   | email  	   |
	| editname | password   | bar@ao3.org  |
  And I am logged in as "editname"
  And I want to edit my profile


Scenario: Add details

  When I fill in the details of my profile
    Then I should see "Your profile has been successfully updated"
	And 0 emails should be delivered

Scenario: Change details

  When I change the details in my profile
    Then I should see "Your profile has been successfully updated"
	And 0 emails should be delivered

Scenario: Remove details

  When I remove details from my profile
    Then I should see "Your profile has been successfully updated"
    And 0 emails should be delivered

Scenario: Changing email address requires reauthenticating

  When I follow "Change Email"
  And I fill in "New Email" with "blah@a.com"
  And I fill in "Confirm New Email" with "blah@a.com"
  And I press "Change Email"
    Then I should see "You must enter your password"
    And 0 emails should be delivered

Scenario: Changing email address - entering an invalid email address

  When I enter an invalid email
	Then I should see "Email does not seem to be a valid address"
	And 0 emails should be delivered

Scenario: Changing email address - entering an incorrect password

  When I enter an incorrect password
    Then I should see "Your password was incorrect"
	And 0 emails should be delivered

Scenario: Changing email address and viewing

  When I change my email
    Then I should see "Your email has been successfully updated"
	And 1 email should be delivered to "bar@ao3.org"
        And the email should contain "the email associated with your account has been changed to"
        And the email should contain "valid2@archiveofourown.org"
        And the email should not contain "translation missing"
	When I change my preferences to display my email address
	  Then I should see "My email address: valid2@archiveofourown.org"

Scenario: Changing email address after requesting temporary password

  When I am logged out
    And I follow "Forgot password?"
    And I fill in "reset_password_for" with "editname"
    And I press "Reset Password"
  Then 1 email should be delivered to "bar@ao3.org"
  When all emails have been delivered
    And I am logged in as "editname"
    And I want to edit my profile
    And I change my email
  Then I should see "Your email has been successfully updated"
    And 1 email should be delivered to "bar@ao3.org"
    And the email should contain "the email associated with your account has been changed to"
    And the email should contain "valid2@archiveofourown.org"
    And the email should not contain "translation missing"
  When I change my preferences to display my email address
  Then I should see "My email address: valid2@archiveofourown.org"

Scenario: Changing email address after requesting temporary password by entering temporary password

  When I am logged out
    And I am on the home page
    And I follow "Forgot password?"
    And I fill in "reset_password_for" with "editname"
    And I press "Reset Password"
  Then 1 email should be delivered to "bar@ao3.org"
  When all emails have been delivered
    And I am logged in as "editname"
    And I want to edit my profile
    And I enter a temporary password for user editname
  Then I should see "Your password was incorrect"
    And 0 emails should be delivered

Scenario: Changing email address -- can't be the same as another user's

  When I enter a duplicate email
	Then I should see "Email has already been taken"
	And 0 emails should be delivered

Scenario: Date of birth - under age

  When I enter a birthdate that shows I am under age
    Then I should see "You must be over 13"

Scenario: Entering date of birth and displaying

  When I fill in my date of birth
    Then I should see "Your profile has been successfully updated"
    When I change my preferences to display my date of birth
    Then I should see "My birthday: 1980-11-30"
	  And 0 emails should be delivered

Scenario: Change password - mistake in typing old password

  When I make a mistake typing my old password
    Then I should see "Your old password was incorrect"

Scenario: Change password - mistake in typing new password confirmation

  When I make a typing mistake confirming my new password
    Then I should see "Password confirmation doesn't match confirmation"

Scenario: Change password

  When I change my password
    Then I should see "Your password has been changed"
	And 0 emails should be delivered
