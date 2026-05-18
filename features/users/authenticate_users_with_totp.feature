@users
Feature: Authenticate Users With TOTP 2FA
  Scenario: Users can enable TOTP 2FA
    Given the following activated users exist
      | login | password     |
      | user  | testpassword |
      And I am logged in as "user" with password "testpassword"
    When I follow "My Preferences"
    Then I should see "Enable Two-Step Verification"
    When I follow "Enable Two-Step Verification"
    Then I should see "Confirm Password"
    When I fill in "Password" with "testpassword"
      And I press "Continue"
    Then I should see "Set Up Two-Step Verification"
    When I fill in a valid TOTP two-step verification code for user "user"
      And I press "Enable Two-Step Verification"
    Then I should see "Successfully enabled two-step verification; please make note of your backup codes."
      And I should see "Finish"
    When I follow "Finish"
    Then I should see "Set My Preferences"
  
  Scenario: Users cannot enable TOTP 2FA if they provide a wrong password
    Given the following activated users exist
      | login | password     |
      | user  | testpassword |
      And I am logged in as "user" with password "testpassword"
    When I follow "My Preferences"
    Then I should see "Enable Two-Step Verification"
    When I follow "Enable Two-Step Verification"
    Then I should see "Confirm Password"
    When I fill in "Password" with "wrongpassword"
      And I press "Continue"
    Then I should see "Your password was incorrect."
      And I should not see "Successfully enabled two-step verification, please make note of your backup codes."
      And I should not see "Finish"
  
  Scenario: Users cannot enable TOTP 2FA if they provide a wrong code
    Given the following activated users exist
      | login | password     |
      | user  | testpassword |
      And I am logged in as "user" with password "testpassword"
    When I follow "My Preferences"
    Then I should see "Enable Two-Step Verification"
    When I follow "Enable Two-Step Verification"
    Then I should see "Confirm Password"
    When I fill in "Password" with "testpassword"
      And I press "Continue"
    Then I should see "Set Up Two-Step Verification"
    When I fill in "6-digit code" with "000000"
      And I press "Enable Two-Step Verification"
    Then I should see "Incorrect verification code. Your code may have expired, or you may need to set up your authenticator app again."
      And I should not see "Successfully enabled two-step verification, please make note of your backup codes."
      And I should not see "Finish"
  
  Scenario: Users can disable TOTP 2FA
    Given the following activated users exist
      | login | password     |
      | user  | testpassword |
      And I am logged in as "user" with password "testpassword"
      And user "user" has TOTP 2FA enabled
    When I follow "My Preferences"
      And I follow "Disable two-step verification"
    Then I should see "Disable Two-Step Verification"
    When I fill in "Password" with "testpassword"
      And I press "Disable"
    Then I should see "Successfully disabled two-step verification."

  Scenario: Users cannot disable TOTP 2FA if they provide a wrong password
    Given the following activated users exist
      | login | password     |
      | user  | testpassword |
      And I am logged in as "user" with password "testpassword"
      And user "user" has TOTP 2FA enabled
    When I follow "My Preferences"
      And I follow "Disable two-step verification"
    Then I should see "Disable Two-Step Verification"
    When I fill in "Password" with "wrongpassword"
      And I press "Disable"
    Then I should see "Your password was incorrect."
      And I should not see "Successfully disabled two-step verification."

  Scenario: Users can regenerate TOTP backup codes
    Given the following activated users exist
      | login | password     |
      | user  | testpassword |
      And I am logged in as "user" with password "testpassword"
      And user "user" has TOTP 2FA enabled
    When I follow "My Preferences"
      And I follow "Re-generate two-step verification backup codes"
    Then I should see "Two-Step Verification Backup Codes"
    When I follow "Finish"
    Then I should see "Set My Preferences"

  Scenario: Users with TOTP 2FA enabled can log in after providing their code
    Given the following activated users exist
      | login | password     |
      | user  | testpassword |
      And user "user" has TOTP 2FA enabled
    When I go to the login page
      And I fill in "Username or email" with "user"
      And I fill in "Password" with "testpassword"
      And I press "Log In"
    Then I should see "Enter the verification code from your authenticator app"
    When I fill in a valid TOTP two-step verification code for user "user"
      And I press "Log In" within "div#main"
    Then I should see "Successfully logged in"

  Scenario: Users with TOTP 2FA enabled can log in after providing their recovery code
    Given the following activated users exist
      | login | password     |
      | user  | testpassword |
      And user "user" has TOTP 2FA enabled
    When I go to the login page
      And I fill in "Username or email" with "user"
      And I fill in "Password" with "testpassword"
      And I press "Log In"
    Then I should see "Enter the verification code from your authenticator app"
    When I fill in a valid TOTP recovery code for user "user"
      And I press "Log In" within "div#main"
    Then I should see "Successfully logged in"
  
  Scenario: Users with TOTP 2FA enabled cannot log in with a used recovery code
    Given the following activated users exist
      | login | password     |
      | user  | testpassword |
      And user "user" has TOTP 2FA enabled
    When I go to the login page
      And I fill in "Username or email" with "user"
      And I fill in "Password" with "testpassword"
      And I press "Log In"
    Then I should see "Enter the verification code from your authenticator app"
    When I fill in a valid TOTP recovery code for user "user"
      And I press "Log In" within "div#main"
    Then I should see "Successfully logged in"
    When I log out
      And I go to the login page
      And I fill in "Username or email" with "user"
      And I fill in "Password" with "testpassword"
      And I press "Log In"
      And I fill in a used TOTP recovery code
      And I press "Log In" within "div#main"
    Then I should see "Incorrect two-step verification code."
      And I should not see "Successfully logged in"

  Scenario: Users with TOTP 2FA enabled should not be prompted for their code if they enter invalid credentials
    Given the following activated users exist
      | login | password     |
      | user  | testpassword |
      And user "user" has TOTP 2FA enabled
    When I go to the login page
      And I fill in "Username or email" with "user"
      And I fill in "Password" with "wrongpassword"
      And I press "Log In"
    Then I should not see "Enter the verification code from your authenticator app"
      And I should see "The password or username you entered doesn't match our records."
  
  Scenario: Users with TOTP 2FA enabled cannot log in after providing a wrong code
    Given the following activated users exist
      | login | password     |
      | user  | testpassword |
      And user "user" has TOTP 2FA enabled
    When I go to the login page
      And I fill in "Username or email" with "user"
      And I fill in "Password" with "testpassword"
      And I press "Log In"
    Then I should see "Enter the verification code from your authenticator app"
    When I fill in "6-digit verification code" with "000000"
      And I press "Log In" within "div#main"
    Then I should see "Incorrect two-step verification code."
      And I should not see "Successfully logged in"
