@admin
Feature: Authenticate Admin Users

  Scenario: admin cannot log in as an ordinary user - it is a different type of account
  Given the following admin exists
      | login       | password |
      | Zooey       | secret   |
  When I go to the home page
      And I fill in "user_login" with "Zooey"
      And I fill in "user_password" with "secret"
      And I press "Log In"
    Then I should see "The password or user name you entered doesn't match our records"

  Scenario: Ordinary user cannot log in as admin
    Given the following activated user exists
      | login       | password      |
      | dizmo       | wrangulator   |
      And I have loaded the "roles" fixture

  When I go to the admin login page
      And I fill in "admin_login" with "dizmo"
      And I fill in "admin_password" with "wrangulator"
      And I press "Log in as admin"
    Then I should not see "Successfully logged in"
      And I should see "Admin user name"

  Scenario: Admin can log in
  Given I have no users
    And the following admin exists
      | login       | password |
      | Zooey       | secret   |
      And I have loaded the "roles" fixture
    When I go to the admin login page
      And I fill in "admin_login" with "Zooey"
      And I fill in "admin_password" with "secret"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"

  Scenario: Login case (in)sensitivity
    Given the following admin exists
      | login       | password |
      | TheMadAdmin | secret   |
    When I go to the admin login page
      And I fill in "admin_login" with "themadadmin"
      And I fill in "admin_password" with "secret"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"
