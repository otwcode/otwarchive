@admin
Feature: Admin Actions to Manage Invitations
  In order to manage user account creation
  As an an admin
  I want to be able to require invitations for new users

  Scenario: Admin can set invite from queue number to a number greater than or equal to 1
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I fill in "admin_setting_invite_from_queue_number" with "0"
      And I press "Update"
    Then I should see "Invite from queue number must be greater than 0. To disable invites, uncheck the appropriate setting."
    When I fill in "admin_setting_invite_from_queue_number" with "1"
      And I press "Update"
    Then I should not see "Invite from queue number must be greater than 0."

  Scenario: Account creation enabled
    Given I am logged in as an admin
      And I go to the admin-settings page      
      And I check "Account creation enabled"
      And I uncheck "Account creation requires invitation"
      And I uncheck "admin_setting_invite_from_queue_enabled"
      And I press "Update"
    When I am logged out as an admin
      And I go to account creation page
    Then I should be on account creation page
      And I should see "Create Account"

  Scenario: Account creation disabled
    Given I am logged in as an admin
      And I go to the admin-settings page 
      And I uncheck "Account creation enabled"
      And I press "Update"
    When I am logged out as an admin
      And I go to account creation page
    Then I should be on the home page
      And I should see "Account creation is suspended at the moment. Please check back with us later."
      # Check to see if the buttons are correct on the main page
      And I should see "Log in or Get an Invite"
      # Check to see if the buttons are correct in the login popup
      And I should see "Forgot password? Get an Invite" within "div#small_login"

  Scenario: Account creation enabled, Invite required, Queue enabled
    Given I am logged in as an admin
      And I go to the admin-settings page 
      And I check "Account creation enabled"
      And I check "Account creation requires invitation"
      And I check "admin_setting_invite_from_queue_enabled"
      And I press "Update"
    When I am logged out as an admin
      And I go to account creation page
    Then I should be on invite requests page
      And I should see "To create an account, you'll need an invitation. One option is to add your name to the automatic queue below."
    Then I go to the home page
      # Check to see if the buttons are correct on the main page
      And I should see "Log in or Get an Invite"
      # Check to see if the buttons are correct in the login popup
      And I should see "Forgot password? Get an Invite" within "div#small_login"

  Scenario: Account creation enabled, Invite is required, Queue is disabled
    Given I am logged in as an admin
      And I go to the admin-settings page 
      And I check "Account creation enabled"
      And I check "Account creation requires invitation"
      And I uncheck "admin_setting_invite_from_queue_enabled"
      And I press "Update"
    When I am logged out as an admin
      And I go to account creation page
    Then I should be on the home page
      And I should see "Account creation currently requires an invitation. We are unable to give out additional invitations at present, but existing invitations can still be used to create an account."
      # Check to see if the buttons are correct on the main page
      And I should see "Log in" within "p#signup"
      And I should not see "Get an Invite" within "p#signup"
      # Check to see if the buttons are correct in the login popup
      And I should see "Forgot password?" within "div#small_login"
      And I should not see "Get an Invite" within "div#small_login"