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

  Scenario: An admin can send an invitation to a user via email
    Given I am logged in as an admin
      And all emails have been delivered
      And I follow "Invite New Users"
     Then I fill in "invitation[invitee_email]" with "fred@bedrock.com"
      And I press "Invite user"
      And I should see "An invitation was sent to fred@bedrock.com"
      And 1 email should be delivered

  Scenario: An admin can't create an invite without an email address.
   Given I am logged in as an admin
      And all emails have been delivered
      And I follow "Invite New Users"
     And I press "Invite user"
      And I should see "Please enter an email address"
      And 0 email should be delivered

  Scenario: An admin can send an invitation to an existing user
    Given the user "dax" exists and is activated
      And I am logged in as an admin
      And I follow "Invite New Users"
      And "dax" should have "0" invitations
     Then I fill in "number_of_invites" with "2"
      And I select "All" from "user_group"
     Then I press "Generate invitations"
      And "dax" should have "2" invitations

  Scenario: An admin can send an invitation to an existing user
   Given the user "dax" exists and is activated
     And the user "bashir" exists and is activated
     And "dax" should have "0" invitations
     And "bashir" should have "0" invitations
     And I am logged in as an admin
    When I am on dax's invitations page
    Then I fill in "number_of_invites" with "5"
     And I press "Create"
    Then "dax" should have "5" invitations
      And I follow "Invite New Users"
     Then I fill in "number_of_invites" with "2"
      And I select "With no unused invitations" from "user_group"
     Then I press "Generate invitations"
      And "dax" should have "5" invitations
      And "bashir" should have "2" invitations

  Scenario: An admin can see the invitation of an existing user via name or token
   Given the user "dax" exists and is activated
     And "dax" should have "0" invitations
     And I am logged in as an admin
    When I am on dax's invitations page
    Then I fill in "number_of_invites" with "2"
     And I press "Create"
    Then "dax" should have "2" invitations 
     And I follow "Invite New Users"
    Then I fill in "user_name" with "dax"
     And I press "Go"
    Then I should see "copy and use"
     And I follow "Invite New Users"
    Then I fill in "token" with "dax's" invite code
     And I press "Go"
    Then I should see "copy and use"

  Scenario: An admin can't find a invitation for a non existant user
   Given I am logged in as an admin
     And I follow "Invite New Users"
    Then I fill in "user_name" with "dax"
     And I press "Go"
    Then I should see "No results were found. Try another search"

  Scenario: An admin can invite people from the queue
   Given I am logged out
     And I ask for an invitation for "fred@bedrock.com"
    Then I ask for an invitation for "barney@bedrock.com"
     And all emails have been delivered
    Then I am logged in as an admin
     And I follow "Invite New Users"
    Then I should see "There are 2 requests in the queue."
    Then I fill in "invite_from_queue" with "1"
     And press "Invite from queue"
    Then I should see "There are 1 requests in the queue."
     And I should see "1 people from the invite queue were invited"
     And 1 email should be delivered

