@admin
Feature: Authenticate Admin Users With TOTP 2FA
  Scenario: Admins can enable TOTP 2FA
    Given the following admin exists
      | login | password     | email             |
      | admin | testpassword | admin@example.com |
      And I am logged in as admin "admin" with password "testpassword"
    When I follow "Set up two-step verification with an authenticator app"
    Then I should see "Confirm Password"
    When I fill in "password" with "testpassword"
      And I press "Continue"
    Then I should see "Two-Step Verification Setup"
    When I fill in a valid TOTP two-step verification code for admin "admin"
      And I press "Enable Two-Step Verification"
    Then I should see "Successfully enabled two-step verification; please make note of your backup codes."
      And I should see "Finish"
  
  Scenario: Admins cannot enable TOTP 2FA if they provide a wrong password
    Given the following admin exists
      | login | password     | email             |
      | admin | testpassword | admin@example.com |
      And I am logged in as admin "admin" with password "testpassword"
    When I follow "Set up two-step verification with an authenticator app"
    Then I should see "Confirm Password"
    When I fill in "password" with "wrongpassword"
      And I press "Continue"
    Then I should see "Your password was incorrect."
      And I should not see "Successfully enabled two-step verification, please make note of your backup codes."
      And I should not see "Finish"
  
  Scenario: Admins cannot enable TOTP 2FA if they provide a wrong code
    Given the following admin exists
      | login | password     | email             |
      | admin | testpassword | admin@example.com |
      And I am logged in as admin "admin" with password "testpassword"
    When I follow "Set up two-step verification with an authenticator app"
    Then I should see "Confirm Password"
    When I fill in "password" with "testpassword"
      And I press "Continue"
    Then I should see "Two-Step Verification Setup"
    When I fill in "totp_attempt" with "000000"
      And I press "Enable Two-Step Verification"
    Then I should see "Incorrect authentication code. Your code may have expired, or you may need to set up your authenticator app again."
      And I should not see "Successfully enabled two-step verification, please make note of your backup codes."
      And I should not see "Finish"
  
  Scenario: Admins can disable TOTP 2FA
    Given the following admin exists
      | login | password     | email             |
      | admin | testpassword | admin@example.com |
      And I am logged in as admin "admin" with password "testpassword"
      And admin "admin" has TOTP 2FA enabled
    When I follow "Hi, admin!"
      And I follow "Disable two-step verification"
    Then I should see "Disable Two-Step Verification"
    When I fill in "password" with "testpassword"
      And I press "Disable"
    Then I should see "Successfully disabled two-step verification."

  Scenario: Admins cannot disable TOTP 2FA if they provide a wrong password
    Given the following admin exists
      | login | password     | email             |
      | admin | testpassword | admin@example.com |
      And I am logged in as admin "admin" with password "testpassword"
      And admin "admin" has TOTP 2FA enabled
    When I follow "Hi, admin!"
      And I follow "Disable two-step verification"
    Then I should see "Disable Two-Step Verification"
    When I fill in "password" with "wrongpassword"
      And I press "Disable"
    Then I should see "Your password was incorrect."
      And I should not see "Successfully disabled two-step verification."

  Scenario: Admins with TOTP 2FA enabled can log in after providing their code
    Given the following admin exists
      | login | password     | email             |
      | admin | testpassword | admin@example.com |
      And admin "admin" has TOTP 2FA enabled
    When I go to the admin login page
      And I fill in "Admin username" with "admin"
      And I fill in "Admin password" with "testpassword"
      And I press "Log In as Admin"
    Then I should see "Two-Step Verification Code"
    When I fill in a valid TOTP two-step verification code for admin "admin"
      And I press "Log In as Admin"
    Then I should see "Successfully logged in"

  Scenario: Admins with TOTP 2FA enabled can log in after providing their recovery code
    Given the following admin exists
      | login | password     | email             |
      | admin | testpassword | admin@example.com |
      And admin "admin" has TOTP 2FA enabled
    When I go to the admin login page
      And I fill in "Admin username" with "admin"
      And I fill in "Admin password" with "testpassword"
      And I press "Log In as Admin"
    Then I should see "Two-Step Verification Code"
    When I fill in a valid TOTP recovery code for admin "admin"
      And I press "Log In as Admin"
    Then I should see "Successfully logged in"
  
  Scenario: Admins with TOTP 2FA enabled cannot log in with a used recovery code
    Given the following admin exists
      | login | password     | email             |
      | admin | testpassword | admin@example.com |
      And admin "admin" has TOTP 2FA enabled
    When I go to the admin login page
      And I fill in "Admin username" with "admin"
      And I fill in "Admin password" with "testpassword"
      And I press "Log In as Admin"
    Then I should see "Two-Step Verification Code"
    When I fill in a valid TOTP recovery code for admin "admin"
      And I press "Log In as Admin"
    Then I should see "Successfully logged in"
    When I log out
      And I go to the admin login page
      And I fill in "Admin username" with "admin"
      And I fill in "Admin password" with "testpassword"
      And I press "Log In as Admin"
      And I fill in a used TOTP recovery code
      And I press "Log In as Admin"
    Then I should see "Incorrect two-step verification code."
      And I should not see "Successfully logged in"

  Scenario: Admins with TOTP 2FA enabled should not be prompted for their code if they enter invalid credentials
    Given the following admin exists
      | login | password     | email             |
      | admin | testpassword | admin@example.com |
      And admin "admin" has TOTP 2FA enabled
    When I go to the admin login page
      And I fill in "Admin username" with "admin"
      And I fill in "Admin password" with "wrongpassword"
      And I press "Log In as Admin"
    Then I should not see "Two-Step Verification Code"
      And I should see "The password or admin username you entered doesn't match our records."
  
  Scenario: Admins with TOTP 2FA enabled cannot log in after providing a wrong code
    Given the following admin exists
      | login | password     | email             |
      | admin | testpassword | admin@example.com |
      And admin "admin" has TOTP 2FA enabled
    When I go to the admin login page
      And I fill in "Admin username" with "admin"
      And I fill in "Admin password" with "testpassword"
      And I press "Log In as Admin"
    Then I should see "Two-Step Verification Code"
    When I fill in "Two-Step Verification Code" with "000000"
      And I press "Log In as Admin"
    Then I should see "Incorrect two-step verification code."
      And I should not see "Successfully logged in"

  # TODO: AO3-7220: Enable the following tests with the requisite changes

#  Scenario: Admins with TOTP 2FA enabled can reset their password after providing their code
#    Given the following admin exists
#      | login | password     | email             |
#      | admin | testpassword | admin@example.com |
#      And admin "admin" has TOTP 2FA enabled
#      And all emails have been delivered
#    When I go to the admin login page
#      And I follow "Forgot admin password?"
#      And I fill in "Admin username" with "admin"
#      And I press "Reset Admin Password"
#      And 1 email should be delivered to "admin@example.com"
#      And I follow "Change my password" in the email
#      And I fill in "New password" with "newpassword"
#      And I fill in "Confirm new password" with "newpassword"
#      And I fill in a valid TOTP recovery code for admin "admin"
#      And I press "Set Admin Password"
#    Then I should see "Your password has been changed. You are now logged in."
#
#  Scenario: Admins with TOTP 2FA enabled cannot reset their password if they provide a wrong code
#    Given the following admin exists
#      | login | password     | email             |
#      | admin | testpassword | admin@example.com |
#      And admin "admin" has TOTP 2FA enabled
#      And all emails have been delivered
#    When I go to the admin login page
#      And I follow "Forgot admin password?"
#      And I fill in "Admin username" with "admin"
#      And I press "Reset Admin Password"
#      And 1 email should be delivered to "admin@example.com"
#      And I follow "Change my password" in the email
#      And I fill in "New password" with "newpassword"
#      And I fill in "Confirm new password" with "newpassword"
#    When I fill in "Two-Step Verification Code" with "000000"
#      And I press "Set Admin Password"
#    Then I should see "Incorrect two-step verification code."
#      And I should not see "Your password has been changed successfully."
#
#  Scenario: Admins with TOTP 2FA disabled cannot see the TOTP field when resetting their password
#    Given the following admin exists
#      | login | password     | email             |
#      | admin | testpassword | admin@example.com |
#      And all emails have been delivered
#    When I go to the admin login page
#      And I follow "Forgot admin password?"
#      And I fill in "Admin username" with "admin"
#      And I press "Reset Admin Password"
#      And 1 email should be delivered to "admin@example.com"
#      And I follow "Change my password" in the email
#    Then I should not see "Two-Step Verification Code"
