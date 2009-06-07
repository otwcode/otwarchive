@users
Feature: Manage Users
  In order to figure out how to use frakking cucumber
  As a humble coder
  I want to figure out how to test login status

	Scenario: Logging in
		Given I create a user named "myname" with password "password"
		And I am logged in as "myname" with password "password"
		Then I should see "Log out"
		
  Scenario Outline: Show or hide preferences link
    Given the following user records
      | login    | password |
      | sam      | secret   |
      | dean     | secret   |
    Given I am logged in as "<login>" with password "secret"
    When I visit user page for "<user>"
    Then I should <action>

    Examples:
      | login | user  | action                   |
      | sam   | sam   | see "My Preferences"     |
      |       | sam   | not see "My Preferences" |
      | sam   | dean  | not see "My Preferences" |
		