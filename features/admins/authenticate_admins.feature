@admin
Feature: Authenticate Admin Users

  Scenario: Admin cannot log in as an ordinary user.
  Given the following admin exists
    | login       | password |
    | Zooey       | secret   |
  When I go to the home page
    And I fill in "User name or email" with "Zooey"
    And I fill in "Password" with "secret"
    And I press "Log In"
  Then I should see "The password or user name you entered doesn't match our records"

  Scenario: Ordinary user cannot log in as admin.
  Given the following activated user exists
    | login       | password      |
    | dizmo       | wrangulator   |
    And I have loaded the "roles" fixture
  When I go to the admin login page
    And I fill in "Admin user name" with "dizmo"
    And I fill in "Admin password" with "wrangulator"
    And I press "Log in as admin"
  Then I should not see "Successfully logged in"
    And I should see "The password or admin user name you entered doesn't match our records."

  Scenario: Admin can log in.
  Given I have no users
    And the following admin exists
      | login       | password |
      | Zooey       | secret   |
    And I have loaded the "roles" fixture
  When I go to the admin login page
    And I fill in "Admin user name" with "Zooey"
    And I fill in "Admin password" with "secret"
    And I press "Log in as admin"
  Then I should see "Successfully logged in"

  Scenario: Admin user name is case insensitive.
  Given the following admin exists
    | login       | password |
    | TheMadAdmin | secret   |
  When I go to the admin login page
    And I fill in "Admin user name" with "themadadmin"
    And I fill in "Admin password" with "secret"
    And I press "Log in as admin"
  Then I should see "Successfully logged in"

  Scenario: Admin cannot log in with wrong password.
  Given the following admin exists
    | login       | password |
    | Zooey       | secret   |
  When I go to the admin login page
    And I fill in "Admin user name" with "Zooey"
    And I fill in "Admin password" with "notsecret"
    And I press "Log In"
  Then I should see "The password or user name you entered doesn't match our records."

