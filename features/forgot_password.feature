Feature: Forgot password
  In order to have an archive full of users
  As an author
  I want to log in

	Scenario: Forgot password
    When I am on the homepage
    Then I should see "Sign Up"
    When I log in as "testuser" with password "test"
    Then I should see "The password you entered doesn't match our records"
    When I follow "forgot password?"
    Then I should see "Never fear - if you've forgotten your password, we can send you a link to reset it"
