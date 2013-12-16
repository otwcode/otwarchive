Feature: Sign Up for a new account
  In order to add works to the Archive.
  As an unregistered user.
  I want to be able to create a new account.

  Scenario: The user should not be able to sign up when there are errors.
    # TODO -- setup is excessive; fix it so we're only initializing what we need
    Given I have no users
      And I have an AdminSetting
      And the following admin exists
      | login       | password   | email                    |
      | admin-sam   | password   | test@archiveofourown.org |
      And the following users exist
      | login | password |
      | user1 | password |
    When I use an invitation to sign up
      And I fill in "user_login" with "user1"
      And I fill in "user_password" with "pass"
      And I press "Create Account"
    Then I should see "Login has already been taken"
      And I should see "Password is too short (minimum is 6 characters)"
      And I should see "Password doesn't match confirmation"
      And I should see "Sorry, you need to accept the Terms of Service in order to sign up."
      And I should see "Sorry, you have to be over 13!"
      And I should not see "Email address is too short"
    When I fill in "user_login" with "newuser"
      And I fill in "user_password" with "password1"
      And I fill in "user_password_confirmation" with "password1"
      And I check "user_age_over_13"
      And I check "user_terms_of_service"
      And I fill in "user_email" with ""
      And I press "Create Account"
    Then I should see "Email does not seem to be a valid address."
    When I fill in "user_email" with "fake@fake@fake"
      And I press "Create Account"
    Then I should see "Email does not seem to be a valid address."
    
  Scenario: The user should be able to create a new account with a valid email and password
    When I use an invitation to sign up
      And I fill in "user_login" with "newuser"
      And I fill in "user_email" with "test@archiveofourown.org"
      And I fill in "user_password" with "password1"
      And I fill in "user_password_confirmation" with "password1"
      And I check "user_age_over_13"
      And I check "user_terms_of_service"
      And all emails have been delivered
    When I press "Create Account"
    Then I should see "Account Created!"
    Then 1 email should be delivered
      And the email should contain "Welcome to the Archive of Our Own,"
      And the email should contain "newuser"
      And the email should contain "Please activate your account"
  # TODO - move to its own scenario
  When all emails have been delivered
      And I click the first link in the email
    Then 1 email should be delivered
      And the email should contain "your account has been activated"
      And I should see "Please log in"
    When I fill in "user_session_login" with "newuser"
      And I fill in "user_session_password" with "password1"
  #    And I press "Log in"
  #  Then I should see "Successfully logged in"
