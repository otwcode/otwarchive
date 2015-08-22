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

  Scenario: Account creation enabled, invitations required, users can request invitations, and the queue is enabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I check "Account creation enabled"
      And I check "Account creation requires invitation"
      And I check "Users can request invitations"
      And I check "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should see "Get Invited!"
      And I should see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should not see "Create An Account"

  Scenario: Account creation enabled, invitations required, users can request invitations, and the queue is disabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I check "Account creation enabled"
      And I check "Account creation requires invitation"
      And I check "Users can request invitations"
      And I uncheck "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should not see "Get Invited!"
      And I should not see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should not see "Create an Account!"

  Scenario: Account creation enabled, invitations required, users cannot request invitations, and the queue is enabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I check "Account creation enabled"
      And I check "Account creation requires invitation"
      And I uncheck "Users can request invitations"
      And I check "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should see "Get Invited!"
      And I should see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should not see "Create an Account!"
    When I go to account creation page
    Then I should be on invite requests page
      And I should see "To create an account, you'll need an invitation. One option is to add your name to the automatic queue below."
      And I should see "Forgot password? Get an Invitation" within "div#small_login"

  Scenario: Account creation enabled, invitations not required, users can request invitations, and the queue is enabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I check "Account creation enabled"
      And I uncheck "Account creation requires invitation"
      And I check "Users can request invitations"
      And I check "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should not see "Get Invited!"
      And I should not see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should see "Create an Account!"

  Scenario: Account creation disabled, invitations required, users can request invitations, and the queue is enabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I uncheck "Account creation enabled"
      And I check "Account creation requires invitation"
      And I uncheck "Users can request invitations"
      And I check "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should see "Get Invited!"
      And I should see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should not see "Create an Account!"

  Scenario: Account creation enabled, invitations required, users cannot request invitations, and the queue is disabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I check "Account creation enabled"
      And I check "Account creation requires invitation"
      And I uncheck "Users can request invitations"
      And I uncheck "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should not see "Get Invited!"
      And I should not see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should not see "Create an Account!"
    When I go to account creation page
    Then I should be on the home page
      And I should see "Account creation currently requires an invitation. We are unable to give out additional invitations at present, but existing invitations can still be used to create an account."
      And I should see "Forgot password?" within "div#small_login"
      And I should not see "Get an Invitation" within "div#small_login"

  Scenario: Account creation enabled, invitations not required, users cannot request invitations, and the queue is enabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I check "Account creation enabled"
      And I uncheck "Account creation requires invitation"
      And I uncheck "Users can request invitations"
      And I check "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should not see "Get Invited!"
      And I should not see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should see "Create an Account!"

  Scenario: Account creation disabled, invitations not required, users can request invitations, and the queue is enabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I uncheck "Account creation enabled"
      And I uncheck "Account creation requires invitation"
      And I check "Users can request invitations"
      And I check "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should not see "Get Invited!"
      And I should not see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should not see "Create an Account!"

  Scenario: Account creation enabled, invitations not required, users can request invitations, and the queue is disabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I check "Account creation enabled"
      And I uncheck "Account creation requires invitation"
      And I check "Users can request invitations"
      And I uncheck "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should not see "Get Invited!"
      And I should not see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should see "Create an Account!"

  Scenario: Account creation disabled, invitations required, users cannot request invitations, and the queue is enabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I uncheck "Account creation enabled"
      And I check "Account creation requires invitation"
      And I uncheck "Users can request invitations"
      And I check "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should see "Get Invited!"
      And I should see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should not see "Create an Account!"

  Scenario: Account creation enabled, invitations not required, users cannot request invitations, and the queue is disabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I check "Account creation enabled"
      And I uncheck "Account creation requires invitation"
      And I uncheck "Users can request invitations"
      And I uncheck "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should not see "Get Invited!"
      And I should not see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should see "Create an Account!"
    When I go to account creation page
    Then I should be on account creation page
      And I should see "Create Account"

  Scenario: Account creation disabled, invitations required, users cannot request invitations, and the queue is disabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I uncheck "Account creation enabled"
      And I check "Account creation requires invitation"
      And I uncheck "Users can request invitations"
      And I uncheck "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should not see "Get Invited!"
      And I should not see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should not see "Create an Account!"

  Scenario: Account creation disabled, invitations not required, users can request invitations, and the queue is disabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I uncheck "Account creation enabled"
      And I uncheck "Account creation requires invitation"
      And I check "Users can request invitations"
      And I uncheck "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should not see "Get Invited!"
      And I should not see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should not see "Create an Account!"

  Scenario: Account creation disabled, invitations not required, users cannot request invitations, and the queue is enabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I uncheck "Account creation enabled"
      And I uncheck "Account creation requires invitation"
      And I uncheck "Users can request invitations"
      And I check "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should not see "Get Invited!"
      And I should not see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should not see "Create an Account!"
    When I go to account creation page
    Then I should be on the home page
      And I should see "Account creation is suspended at the moment. Please check back with us later."
      And I should see "Forgot password? Get an Invitation" within "div#small_login"

  Scenario: Account creation disabled, invitations not required, users cannot request invitations, and the queue is disabled
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I uncheck "Account creation enabled"
      And I uncheck "Account creation requires invitation"
      And I uncheck "Users can request invitations"
      And I uncheck "Invite from queue enabled (People can add themselves to the queue and invitations are sent out automatically)"
      And I press "Update"
      And I am logged out as an admin
    When I go to the home page
    Then I should not see "Get Invited!"
      And I should not see "While the site is in beta, you can join by getting an invitation from another user or from our automated invite queue. All fans and fanworks are welcome!"
      And I should not see "Create an Account!"
