@users
Feature: User Authentication

  Scenario: Forgot password
    Given I have no users
      And the following activated user exists
      | login    | password | 
      | sam      | secret   |
      And all emails have been delivered
    When I am logged in as "sam" with password "test"
    Then I should see "The password you entered doesn't match our records"
    When I follow "forgot password?"
    Then I should see "Never fear - if you've forgotten your password, we can send you a link to reset it"
    When I fill in "login" with "sam"
      And I press "Reset password"
    Then 1 email should be delivered

  Scenario: Logged out
    Given I have no users
     And a user exists with login: "sam"
    When I am on sam's user page
      Then I should see "Log in"
      Then I should not see "Log out"
      And I should not see "My Preferences"

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
      | sam   | sam   | not see "Log in"         |
      | sam   | sam   | see "Log out"            |
      | sam   | sam   | see "My Preferences"     |
      | sam   | dean  | see "Log out"            |
      | sam   | dean  | not see "My Preferences" |
      | sam   | dean  | not see "Log in"         |

