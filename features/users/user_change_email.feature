@users
Feature:
  As a registered user
  I should be able to change my email

  Scenario: The user should not be able to change email without a password
    Given I am logged in as "testuser" with password "password"
    When I visit the change email page for "testuser"
      And I fill in "New Email" with "new_email@test.com"
      And I fill in "Confirm New Email" with "new_email@test.com"
      And I press "Change Email"
    Then I should see "You must enter your password"

  Scenario: The user should not be able to change their email with an incorrect password
    Given I am logged in as "testuser" with password "password"
    When I visit the change email page for "testuser"
      And I fill in "New Email" with "new_email@test.com"
      And I fill in "Confirm New Email" with "new_email@test.com"
      And I fill in "Password" with "wrongpwd"
      And I press "Change Email"
    Then I should see "Your password was incorrect"

  Scenario: The user should not be able to change their email when new email does not match
    Given I am logged in as "testuser" with password "password"
    When I visit the change email page for "testuser"
      And I fill in "New Email" with "new_email@test.com"
      And I fill in "Confirm New Email" with "wrong_email@test.com"
      And I fill in "Password" with "password"
      And I press "Change Email"
    Then I should see "Email addresses don't match! Please retype and try again."

  Scenario: The user should be able to change their email if new email and password are valid
    Given I am logged in as "testuser" with password "password"
    When I visit the change email page for "testuser"
      And I fill in "New Email" with "new_email@test.com"
      And I fill in "Confirm New Email" with "new_email@test.com"
      And I fill in "Password" with "password"
      And I press "Change Email"
    Then I should see "Your email has been successfully updated"
      And I should see "new_email@test.com"
      And "testuser" default email is changed to "new_email@test.com"

  Scenario: The user should get notification email when email is changed
    Given the following activated user exists
      | login      | email                  | password |
      | testuser   | old_email@test.com     | password |
      And I am logged in as "testuser"
      And all emails have been delivered
    When I visit the change email page for "testuser"
      And I fill in "New Email" with "new_email@test.com"
      And I fill in "Confirm New Email" with "new_email@test.com"
      And I fill in "Password" with "password"
      And I press "Change Email"
    Then "testuser" old email "old_email@test.com" should be emailed
      And the email should have "Email changed" in the subject
      And the email should not contain "Translated footer" 
      And the email should contain "fan-run and fan-supported archive"
      And the email should not contain "translation missing"

  Scenario: Translated email is sent when email is changed
    Given a locale with translated emails
      And the following activated user exists
      | login      | email                  | password |
      | testuser   | old_email@test.com     | password |
      And the user "testuser" enables translated emails
      And I am logged in as "testuser"
      And all emails have been delivered
    When I visit the change email page for "testuser"
      And I fill in "New Email" with "new_email@test.com"
      And I fill in "Confirm New Email" with "new_email@test.com"
      And I fill in "Password" with "password"
      And I press "Change Email"
    Then "testuser" old email "old_email@test.com" should be emailed
      And the email should have "Email changed" in the subject
      And the email should contain "Translated footer" 
      And the email should not contain "fan-run and fan-supported archive"
      And the email should not contain "translation missing"
