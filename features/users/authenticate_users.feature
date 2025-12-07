@users
@admin
Feature: User Authentication

  Scenario: Forgot password
    Given I have no users
      And the following activated user exists
      | email           | login | password |
      | sam@example.com | sam   | secret   |
      And all emails have been delivered
    When I am on the home page
      And I fill in "Username or email:" with "sam"
      And I fill in "Password:" with "test"
      And I press "Log In"
    Then I should see "The password or username you entered doesn't match our records"
      And I should see "Forgot your password or username?"
    When I follow "Reset your password"
    Then I should see "If you've forgotten your password, we can send you an email with instructions to reset your password."
      And I should see the page title "Reset Password"
    When I fill in "Email address" with "sam@example.com"
      And I press "Reset Password"
    Then I should see "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password."
      And 1 email should be delivered
      And the email should contain "sam"
      And the email should contain "Someone has made a request to reset the password for your AO3 account."
      And the email should not contain "translation missing"

    # existing password should still work
    When I am on the homepage
      And I fill in "Username or email:" with "sam"
      And I fill in "Password:" with "secret"
      And I press "Log In"
    Then I should see "Hi, sam"

    # link from the email should not work when logged in
    When I follow "use this link to choose a new password" in the email
    Then I should see "You are already logged in to an account. Please log out and try again."
      And I should not see "Change Password"

    # link from the email should work
    When I log out
      And I follow "use this link to choose a new password" in the email
    Then I should see "Change Password"

    # entering mismatched passwords should produce an error message
    When I fill in "New password" with "secret"
      And I fill in "Confirm new password" with "newpass"
      And I press "Change Password"
    Then I should see "We couldn't save this user because:"
      And I should see "The passwords you entered do not match. Please try again."

    # and I should be able to change the password
    When I fill in "New password" with "new<pass"
      And I fill in "Confirm new password" with "new<pass"
      And I press "Change Password"
    Then I should see "Your password has been changed. You are now logged in."
      And I should see "Hi, sam"

    # password reset link should no longer work
    When I log out
      And I follow "use this link to choose a new password" in the email
    Then I should see "This password reset link is invalid or expired. Please check your email for the most recent password reset link."
      And I should be on the forgot password page

    # old password should no longer work
    When I am on the homepage
      And I fill in "Username or email:" with "sam"
      And I fill in "Password:" with "secret"
      And I press "Log In"
    Then I should not see "Hi, sam"

    # new password should work
    When I am on the homepage
      And I fill in "Username or email:" with "sam"
      And I fill in "Password:" with "new<pass"
      And I press "Log In"
    Then I should see "Hi, sam"

    # password entered the second time should not work
    When I log out
      And I am on the homepage
      And I fill in "Username or email:" with "sam"
      And I fill in "Password:" with "override"
      And I press "Log In"
    Then I should not see "Hi, sam"

  Scenario: Users should not be able to request password resets with their username
    Given I have no users
      And the following activated user exists
      | email           | login | password |
      | sam@example.com | sam   | secret   |
      And all emails have been delivered
    When I request a password reset for "sam"
    Then I should see "You must enter your email address."
      And I should not see "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password."
      And 0 email should be delivered
  
  Scenario: Attackers should see a fake success message when requesting password resets with a non-existant email
    Given I have no users
      And the following activated user exists
      | email           | login | password |
      | sam@example.com | sam   | secret   |
      And all emails have been delivered
    When I request a password reset for "1@example.com"
    Then I should see "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password."
      And 0 email should be delivered

  Scenario: Translated reset password email and password change email
    Given a locale with translated emails
      And the following activated users exist
        | login    | email              | password |
        | sam      | sam@example.com    | password |
        | notsam   | notsam@example.com | password |
      And the user "sam" enables translated emails
      And all emails have been delivered
    When I request a password reset for "sam@example.com"
    Then I should see "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password."
      And 1 email should be delivered to "sam@example.com"
      And the email should have "Translated subject" in the subject
      And the email to "sam" should be translated
    # notsam didn't enable translated emails
    When I request a password reset for "notsam@example.com"
    Then I should see "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password."
      And 1 email should be delivered to "notsam@example.com"
      And the email should have "Reset your password" in the subject
      And the email to "notsam" should be non-translated
      And 1 email should be delivered to "sam@example.com"
    When I follow "use this link to choose a new password" in the email
      And all emails have been delivered
      And I fill in "New password" with "newpass"
      And I fill in "Confirm new password" with "newpass"
      And I press "Change Password"
    Then I should see "Your password has been changed."
      And 1 email should be delivered to "sam"
      And the email should have "Your password has been changed" in the subject
      And the email to "sam" should be translated

  Scenario: Forgot password, logging in with email address
    Given I have no users
      And the following activated user exists
        | login | email           | password |
        | sam   | sam@example.com | password |
      And all emails have been delivered
    When I request a password reset for "sam@example.com"
    Then I should see "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password."
      And 1 email should be delivered
    When I start a new session
      And I follow "use this link to choose a new password" in the email
      And I fill in "New password" with "newpass"
      And I fill in "Confirm new password" with "newpass"
      And I press "Change Password"
    Then I should see "Your password has been changed."
      And I should see "Hi, sam"

  Scenario: Forgot password, with expired password token
    Given I have no users
      And the following activated user exists
        | login | email           | password |
        | sam   | sam@example.com | password |
      And all emails have been delivered
    When I request a password reset for "sam@example.com"
    Then I should see "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password."
      And 1 email should be delivered
    When it is currently 2 weeks from now
      And I start a new session
      And I follow "use this link to choose a new password" in the email
      And I fill in "New password" with "newpass"
      And I fill in "Confirm new password" with "newpass"
      And I press "Change Password"
    Then I should see "We couldn't save this user because:"
      And I should see "Reset password token has expired, please request a new one"
      And I should see "Log In"
      And I should not see "Your password has been changed"
      And I should not see "Hi, sam!"
    When I am logged in as a super admin
      And I go to the user administration page for "sam"
    Then I should not see "Password Reset" within "#user_history"

  Scenario: Forgot password, with enough attempts to trigger password reset cooldown
    Given I have no users
      And the following activated user exists
        | login | email           | password |
        | sam   | sam@example.com | password |
      And all emails have been delivered
    When I request a password reset for "sam@example.com"
      And I request a password reset for "sam@example.com"
      And I request a password reset for "sam@example.com"
    Then I should see "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password."
      And 3 emails should be delivered
    When all emails have been delivered
      And I request a password reset for "sam@example.com"
    Then I should see "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password."
      And 0 emails should be delivered
    When it is currently 12 hours from now
      And I request a password reset for "sam@example.com"
    Then I should see "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password."
      And 1 email should be delivered

  Scenario: Resetting password adds admin log item
    Given the following activated user exists
      | login | email           |
      | sam   | sam@example.com |
      And all emails have been delivered
    When I request a password reset for "sam@example.com"
    Then 1 email should be delivered
    When I am logged in as a super admin
      And I go to the user administration page for "sam"
    Then I should not see "Password Reset" within "#user_history"
    When I start a new session
      And I follow "use this link to choose a new password" in the email
      And I fill in "New password" with "newpass"
      And I fill in "Confirm new password" with "newpass"
      And I press "Change Password"
    Then I should see "Your password has been changed."
    When I am logged in as a super admin
      And I go to the user administration page for "sam"
    Then I should see "Password Reset" within "#user_history"
      But I should not see "Password Changed" within "#user_history"

  Scenario: User is locked out
    Given I have no users
      And the following activated user exists
        | login | password |
        | sam   | password |
      And all emails have been delivered
      And the user "sam" has failed to log in 50 times
      When I am on the home page
        And I fill in "Username or email:" with "sam"
        And I fill in "Password:" with "badpassword"
        And I press "Log In"
      Then I should see "Your account has been locked for 5 minutes"
        And I should not see "Hi, sam!"

      # User should not be able to log back in even with correct password
      When I am on the home page
        And I fill in "Username or email:" with "sam"
        And I fill in "Password:" with "password"
        And I press "Log In"
      Then I should see "Your account has been locked for 5 minutes"
        And I should not see "Hi, sam!"

      # User should be able to log in with the correct password 5 minutes later
      When it is currently 5 minutes from now
        And I am on the home page
        And I fill in "Username or email:" with "sam"
        And I fill in "Password:" with "password"
        And I press "Log In"
      Then I should see "Successfully logged in."
        And I should see "Hi, sam!"

  Scenario: Wrong username
    Given I have no users
      And the following activated user exists
      | login    | password |
      | sam      | secret   |
      And all emails have been delivered
    When I am on the home page
      And I fill in "Username or email:" with "sammy"
      And I fill in "Password:" with "test"
      And I press "Log In"
    Then I should see "The password or username you entered doesn't match our records. Please try again or reset your password. If you still can't log in, please visit Problems When Logging In for help."

  Scenario: Wrong password
    Given I have no users
      And the following activated user exists
      | login    | password |
      | sam      | secret   |
      And all emails have been delivered
    When I am on the home page
      And I fill in "Username or email:" with "sam"
      And I fill in "Password:" with "tester"
      And I press "Log In"
    Then I should see "The password or username you entered doesn't match our records. Please try again or reset your password. If you still can't log in, please visit Problems When Logging In for help."

  Scenario: Logged out
    Given I have no users
     And a user exists with login: "sam"
    When I am on sam's user page
    Then I should see "Log In"
      And I should not see "Log Out"
      And I should not see "Preferences"

  Scenario: Login case (in)sensitivity
    Given the following activated user exists
      | login      | password  |
      | TheMadUser | password1 |
    When I am on the home page
      And I fill in "Username or email:" with "themaduser"
      And I fill in "Password:" with "password1"
      And I press "Log In"
    Then I should see "Successfully logged in."
      And I should see "Hi, TheMadUser!"

  Scenario: Login with email
    Given the following activated user exists
      | login      | email                  | password |
      | TheMadUser | themaduser@example.com | password |
    When I am on the home page
      And I fill in "Username or email:" with "themaduser@example.com"
      And I fill in "Password:" with "password"
      And I press "Log In"
      Then I should see "Successfully logged in."
        And I should see "Hi, TheMadUser!"

  Scenario: Not using remember me gives a warning about length of session
    Given the following activated user exists
      | login   | password |
      | MadUser | password |
    When I am on the home page
      And I fill in "Username or email:" with "maduser"
      And I fill in "Password:" with "password"
      And I press "Log In"
    Then I should see "Successfully logged in."
      And I should see "You'll stay logged in for 2 weeks even if you close your browser"

  Scenario Outline: Passwords cannot be reset for users with certain roles.
    Given the following activated user exists
      | login  | email            |
      | target | user@example.com |
      And the user "target" <role>
    When I am on the home page
      And I follow "Forgot password?"
      And I fill in "Email address" with "user@example.com"
      And I press "Reset Password"
    Then I should be on the new user password page
      And I should see "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password."
      And 0 emails should be delivered

    Examples:
      | role                   |
      | is a protected user    |
      | has the no resets role |

  Scenario: Admin cannot log in or reset password as ordinary user.
    Given the following admin exists
      | login | password      |
      | admin | adminpassword |
    When I go to the login page
      And I fill in "Username or email" with "admin"
      And I fill in "Password" with "adminpassword"
      And I press "Log In"
    Then I should not see "Successfully logged in"
      And I should see "The password or username you entered doesn't match our records."
    When I am logged in as an admin
      And I go to the forgot password page
    Then I should be on the homepage
      And I should see "Please log out of your admin account first!"
    When I go to the edit user password page
    Then I should be on the homepage
      And I should see "Please log out of your admin account first!"

  @no-js-emulation
  Scenario: Log out with javascript disabled redirects to page prior to log out
    Given I am logged in
      And I am on the works page
    When I follow "Log Out"
    Then I should see "Are you sure you want to log out?"
    When I press "Yes, Log Out"
    Then I should see "Successfully logged out."
      And I should be on the works page

  Scenario: User is redirected back to restricted work after login
    Given I am logged in as "test" with password "password"
      And I post the locked work "Secret"
      And I log out
    When I view the work "Secret"
    Then I should see "Sorry!"
      And I should see "This work is only available to registered users of the Archive."
    When I fill in "Username or email:" with "test" within "#main"
      And I fill in "Password:" with "password" within "#main"
      And I press "Log in" within "#main"
    Then I should see "Secret"

  Scenario: User is redirected to previous page after using the small login
    Given the following activated user exists
      | login | password |
      | test  | password |
      And I am on the works page
    When I fill in "Username or email:" with "test" within "#small_login"
      And I fill in "Password:" with "password" within "#small_login"
      And I press "Log In" within "#small_login"
    Then I should be on the works page

  Scenario: User is redirected to previous page after using the main login
    Given the following activated user exists
      | login | password |
      | test  | password |
      And I am on the works page
    When I follow "Log In"
    Then I should see "Log in" within "#main"
    When I fill in "Username or email:" with "test" within "#main"
      And I fill in "Password:" with "password" within "#main"
      And I press "Log in" within "#main"
    Then I should be on the works page

  Scenario: User is redirected to previous page after inputting the wrong credentials in the small login
    Given the following activated user exists
      | login | password |
      | test  | password |
      And I am on the works page
    When I fill in "Username or email:" with "test" within "#small_login"
      And I fill in "Password:" with "badpassword" within "#small_login"
      And I press "Log In" within "#small_login"
    Then I should see "The password or username you entered doesn't match our records."
    When I fill in "Username or email:" with "test" within "#main"
      And I fill in "Password:" with "password" within "#main"
      And I press "Log in" within "#main"
    Then I should be on the works page

  Scenario: User is redirected to previous page after using the small login on the main login page
    Given the following activated user exists
      | login | password |
      | test  | password |
      And I am on the works page
    When I follow "Log In"
    Then I should see "Log in" within "#main"
    When I fill in "Username or email:" with "test" within "#small_login"
      And I fill in "Password:" with "password" within "#small_login"
      And I press "Log In" within "#small_login"
    Then I should be on the works page
