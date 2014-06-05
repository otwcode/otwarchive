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
    When I fill in "login" with "sam"
      And I press "Reset password"
    Then 1 email should be delivered

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
    And I should see "Change My Password"

    # and I should be able to change the password
    When I fill in "New Password" with "newpass"
    And I fill in "Confirm New Password" with "newpass"
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

  Scenario: invalid user
    Given I have loaded the "users" fixture
    When I am on the home page
    And I follow "Forgot password?"
    When I fill in "login" with "testuser"
      And I press "Reset password"
    Then I should see "Check your email"
      And 1 email should be delivered

    # password from email should work
    When I fill in "User name" with "testuser"
    And I fill in "testuser"'s temporary password
    And I press "Log In"
    Then I should see "Hi, testuser"
    And I should see "Change My Password"

    # and I should be able to change the password
    When I fill in "New Password" with "newpas"
    And I fill in "Confirm New Password" with "newpas"
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
    Then I should see "The password or user name you entered doesn't match our records. Please try again or click the 'forgot password' link below."

  Scenario: Logged out
    Given I have no users
     And a user exists with login: "sam"
    When I am on sam's user page
    Then I should see "Log In"
      And I should not see "Log Out"
      And I should not see "Preferences"

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

