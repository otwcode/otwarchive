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
    When I fill in "reset_password_for" with "sam"
      And I press "Reset Password"
    Then 1 email should be delivered
      And the email should contain "the following generated password has been created for you"
      And the email should contain "sam"
      And the email should not contain "translation missing"

    # old password should still work
    When I am on the homepage
      And I fill in "User name" with "sam"
      And I fill in "Password" with "secret"
      And I press "Log In"
    Then I should see "Hi, sam"

    # password from email should also work
    When I am logged out
      And I fill in "User name" with "sam"
      And I fill in "sam"'s temporary password
      And I press "Log In"
    Then I should see "Hi, sam"
      And I should see "You used a temporary password to log in."
      And I should see "Change My Password"

    # and I should be able to change the password
    When I fill in "New password" with "newpass"
      And I fill in "Confirm new password" with "newpass"
      And I press "Change Password"
    Then I should see "Your password has been changed"

    # old password should no longer work
    When I am logged out
    When I am on the homepage
      And I fill in "User name" with "sam"
      And I fill in "Password" with "secret"
      And I press "Log In"
    Then I should not see "Hi, sam"

    # generated password should no longer work
    When I am logged out
    When I am on the homepage
      And I fill in "User name" with "sam"
      And I fill in "sam"'s temporary password
      And I press "Log In"
    Then I should not see "Hi, sam"

    # new password should work
    When I am logged out
    When I am on the homepage
      And I fill in "User name" with "sam"
      And I fill in "Password" with "newpass"
      And I press "Log In"
    Then I should see "Hi, sam"

  Scenario: Forgot password, logging in with email address
    Given I have no users
      And the following activated user exists
        | login | email           | password |
        | sam   | sam@example.com | password |
      And all emails have been delivered
    When I am on the login page
      And I follow "Reset password"
      And I fill in "Email address or user name" with "sam@example.com"
      And I press "Reset Password"
    Then 1 email should be delivered
    When I am logged out
      And I fill in "User name" with "sam@example.com"
      And I fill in "sam"'s temporary password
      And I press "Log In"
    Then I should see "Hi, sam"
      And I should see "You used a temporary password to log in."
      And I should see "Change My Password"

  Scenario: With expired password token
    Given I have no users
      And the following activated user exists
        | login | password |
        | sam   | password |
      And all emails have been delivered
    When I am on the login page
      And I follow "Reset password"
      And I fill in "Email address or user name" with "sam"
      And I press "Reset Password"
    Then 1 email should be delivered
    When I am logged out
      And the password reset token for "sam" is expired
    When I fill in "User name" with "sam"
      And I fill in "sam"'s temporary password
      And I press "Log In"
    Then I should see "The password you entered has expired."
      And I should not see "Hi, sam!"
      And I should see "Log In"

  Scenario: User is locked out
    Given I have no users
      And the following activated user exists
        | login | password |
        | sam   | password |
      And all emails have been delivered
      And the user "sam" has failed to log in 50 times
      When I am on the home page
        And I fill in "User name" with "sam"
        And I fill in "Password" with "badpassword"
        And I press "Log In"
      Then I should see "Your account has been locked for 5 minutes"
        And I should not see "Hi, sam!"

      # User should not be able to log back in even with correct password
      When I am on the home page
        And I fill in "User name" with "sam"
        And I fill in "Password" with "password"
        And I press "Log In"
      Then I should see "Your account has been locked for 5 minutes"
        And I should not see "Hi, sam!"

      # User should be able to log in with the correct password 5 minutes later
      When it is currently 5 minutes from now
        And I am on the home page
        And I fill in "User name" with "sam"
        And I fill in "Password" with "password"
        And I press "Log In"
      Then I should see "Successfully logged in."
        And I should see "Hi, sam!"

  Scenario: invalid user
    Given I have loaded the fixtures
    When I am on the home page
    And I follow "Forgot password?"
    When I fill in "reset_password_for" with "testuser"
      And I press "Reset Password"
    Then I should see "Check your email"
      And 1 email should be delivered

    # password from email should work
    When I fill in "User name" with "testuser"
      And I fill in "testuser"'s temporary password
      And I press "Log In"
    Then I should see "Hi, testuser"
      And I should see "Change My Password"

    # and I should be able to change the password
    When I fill in "New password" with "newpas"
      And I fill in "Confirm new password" with "newpas"
      And I press "Change Password"
    Then I should see "Your password has been changed"

    # new password should work
    When I am logged out
    When I am on the homepage
      And I fill in "User name" with "testuser"
      And I fill in "Password" with "newpas"
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
    Then I should see "The password or user name you entered doesn't match our records. Please try again or reset your password. If you still can't log in, please visit Problems When Logging In for help."

  Scenario: Logged out
    Given I have no users
     And a user exists with login: "sam"
    When I am on sam's user page
    Then I should see "Log In"
      And I should not see "Log Out"
      And I should not see "Preferences"

  Scenario: Login case (in)sensitivity
    Given the following activated user exists
      | login      | password |
      | TheMadUser | password1 |
    When I am on the home page
      And I fill in "User name" with "themaduser"
      And I fill in "Password" with "password1"
      And I press "Log In"
    Then I should see "Successfully logged in."
      And I should see "Hi, TheMadUser!"

  Scenario: Login with email
    Given the following activated user exists
      | login      | email                  | password |
      | TheMadUser | themaduser@example.com | password |
    When I am on the home page
      And I fill in "User name" with "themaduser@example.com"
      And I fill in "Password" with "password"
      And I press "Log In"
      Then I should see "Successfully logged in."
        And I should see "Hi, TheMadUser!"

  Scenario: Not using remember me gives a warning about length of session
    Given the following activated user exists
      | login   | password |
      | MadUser | password |
    When I am on the home page
      And I fill in "User name" with "maduser"
      And I fill in "Password" with "password"
      And I press "Log In"
    Then I should see "Successfully logged in."
      And I should see "You'll stay logged in for 2 weeks even if you close your browser"

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
