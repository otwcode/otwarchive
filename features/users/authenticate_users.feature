@users
@admin
Feature: User Authentication

  Scenario: Forgot password
    Given I have no users
      And the following activated user exists
      | login    | password |
      | sam      | secret   |
      And all emails have been delivered
    When I am on the home page
      And I fill in "User name" with "sam"
      And I fill in "Password" with "test"
      And I press "Log In"
    Then I should see "The password or user name you entered doesn't match our records"
    And I should see "Forgot your password or user name?"
    When I follow "Reset password"
    Then I should see "Please tell us the user name or email address you used when you signed up for your Archive account"
    When I fill in "user_reset_password_for" with "sam"
      And I press "Reset Password"
    Then I should see "You will receive an email with instructions on how to reset your password in a few minutes"
      And 1 email should be delivered

    # actual password should still work
    When I am on the homepage
    And I fill in "User name" with "sam"
    And I fill in "Password" with "secret"
    And I press "Log In"
    Then I should see "Hi, sam"

    # user follow emailed link to create a new password
    When I am logged out
    Then the email should contain "Someone has requested a link to change your password."
    When I click the first link in the email
      And I fill in "New password" with "newpass" within "#new_user"
      And I fill in "Confirm new password" with "newpass" within "#new_user"
      And I press "Change my password"
    Then I should see "Your password has been changed successfully"

    # old password should no longer work
    When I am logged out
    When I am on the homepage
    And I fill in "User name" with "sam"
    And I fill in "Password" with "secret"
    And I press "Log In"
    Then I should not see "Hi, sam"

    # new password should work
    When I am logged out
    When I am on the homepage
    And I fill in "User name" with "sam"
    And I fill in "Password" with "newpass"
    And I press "Log In"
    Then I should see "Hi, sam"

  Scenario: invalid user
    Given I have loaded the fixtures
    When I am on the home page
    And I follow "Forgot password?"
    When I fill in "user_reset_password_for" with "testuser"
      And I press "Reset Password"
    Then I should see "You will receive an email with instructions on how to reset your password in a few minutes"
      And 1 email should be delivered

    # user follow emailed link to create a new password
    When I am logged out
    Then the email should contain "Someone has requested a link to change your password."
    When I click the first link in the email
      And I fill in "New password" with "newpass" within "#new_user"
      And I fill in "Confirm new password" with "newpass" within "#new_user"
      And I press "Change my password"
    Then I should see "Your password has been changed successfully"

    # new password should work
    When I am logged out
    When I am on the homepage
    And I fill in "User name" with "testuser"
    And I fill in "Password" with "newpass"
    And I press "Log In"
    Then I should see "Hi, testuser"

  Scenario: Wrong username
    Given I have no users
      And the following activated user exists
      | login    | password |
      | sam      | secret   |
      And all emails have been delivered
    When I am on the home page
      And I fill in "User name" with "sammy"
      And I fill in "Password" with "test"
      And I press "Log In"
    Then I should see "The password or user name you entered doesn't match our records."

  Scenario: Wrong username
    Given I have no users
      And the following activated user exists
      | login    | password |
      | sam      | secret   |
      And all emails have been delivered
    When I am on the home page
      And I fill in "User name" with "sam"
      And I fill in "Password" with "tester"
      And I press "Log In"
    Then I should see "The password or user name you entered doesn't match our records. Please try again or follow the 'Forgot password?' link below."

  Scenario: Logged out
    Given I have no users
     And a user exists with login: "sam"
    When I am on sam's user page
    Then I should see "Log In"
      And I should not see "Log Out"
      And I should not see "Preferences"

  # TODO make this an actual test - it's been 4 years...
  Scenario Outline: Show or hide preferences link
    Given I have no users
      And the following activated users exist
      | login    | password |
      | sam      | secret   |
      | dean     | secret   |
    And I am logged in as "<login>" with password "secret"
    When I am on <user>'s user page
    Then I should <action>

    Examples:
      | login | user  | action                   |
      | sam   | sam   | not see "Log In"         |
      | sam   | sam   | see "Log Out"            |
      | sam   | sam   | see "Preferences" within "#dashboard"    |
      | sam   | dean  | see "Log Out"            |
      | sam   | dean  | not see "Preferences" within "#dashboard" |
      | sam   | dean  | not see "Log In"         |

