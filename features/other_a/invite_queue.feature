@admin
Feature: Invite queue management

  Background:
    Given I have no users
    And I have an AdminSetting
    And the following admin exists
      | login       | password   | email                    |
      | admin-sam   | password   | test@archiveofourown.org |
    And the following users exist
      | login | password |
      | user1 | password |

  Scenario: Can turn queue off in Admin Settings and it displays as off
  
    Given I am logged in as an admin
      And I go to the admin-settings page
      And I uncheck "admin_setting_invite_from_queue_enabled"
      And I press "Update"
    When I am logged out as an admin
      And I am on the homepage
    Then I should not see "Get an Invite"
      And I should see "Archive of Our Own"
  
  Scenario: Can turn queue on in Admin Settings and it displays as on
  
    Given I am logged in as an admin
      And account creation requires an invitation
      And I go to the admin-settings page
      And I check "admin_setting_invite_from_queue_enabled"
      And I press "Update"
    When I am logged out as an admin
      And I am on the homepage
    Then I should see "Get an Invite"
    When I follow "Get an Invite"
    Then I should see "Request an Invite"

  Scenario: Visitors can join the queue and check status when invitations are required and the queue is enabled

    # join queue
    Given I am a visitor
      And account creation requires an invitation
      And the invitation queue is enabled
    When I am on the homepage
      And all emails have been delivered
      And I follow "Get an Invite"
    Then I should see "We are sending out 10 invitations per day."
    When I fill in "invite_request_email" with "test@archiveofourown.org"
      And I press "Add me to the list"
    Then I should see "You've been added to our queue"
    
    # check your place in the queue - invalid address
    When I check how long "testttt@archiveofourown.org" will have to wait in the invite request queue
    Then I should see "You can search for the email address you signed up with below."
      And I should see "If you can't find it, your invitation may have already been emailed to that address; please check your email Spam folder as your spam filters may have placed it there."
      And I should not see "You are currently number"
    
    # check your place in the queue - correct address
    When I check how long "test@archiveofourown.org" will have to wait in the invite request queue
    Then I should see "Invitation Status for test@archiveofourown.org"
      And I should see "You are currently number 1 on our waiting list! At our current rate, you should receive an invitation on or around"

  Scenario: Can't add yourself to the queue when queue is off
  
    Given the invitation queue is disabled
    When I go to the invite_requests page
    Then I should not see "Add yourself to the list"
      And I should not see "invite_request_email"
  
  Scenario: Can still check status when queue is off
  
    Given the invitation queue is disabled
      And I am logged out as an admin
    When I go to the invite_requests page
    Then I should see "Wondering how long you'll have to wait"
      And I should see "Email"

  Scenario: The queue sends out invites and user can create and activate an account

    Given account creation is enabled
      And the invitation queue is enabled
      And account creation requires an invitation
      And the invite_from_queue_at is yesterday
    When I am on the homepage
      And all emails have been delivered
      And I follow "Get an Invite"
    When I fill in "invite_request_email" with "test@archiveofourown.org"
      And I press "Add me to the list"
      And the check_queue rake task is run
    Then 1 email should be delivered to test@archiveofourown.org
    When I check how long "test@archiveofourown.org" will have to wait in the invite request queue
    Then I should see "You can search for the email address you signed up with below."
      And I should see "If you can't find it, your invitation may have already been emailed to that address;"
    
    # invite can be used
    When I am logged in as an admin
      And I follow "Invitations"
      And I fill in "invitee_email" with "test@archiveofourown.org"
      And I press "Go"
    Then I should see "Sender queue"
    When I follow "copy and use"
    Then I should see "You are already logged in!"

    # user uses email invite
    Given I am a visitor
    Then the email should contain "You've been invited to join our beta!"
      And the email should contain "fanart"
      And the email should contain "podfic"
    When I click the first link in the email
      And I fill in the sign up form with valid data
      And I fill in the following:
        | user_login                 | newuser                  |
        | user_email                 | test@archiveofourown.org |
        | user_password              | password1                |
        | user_password_confirmation | password1                |
      And all emails have been delivered
    When I press "Create Account"
    Then I should see "Account Created!"
    Then 1 email should be delivered
      And the email should contain "Welcome to the Archive of Our Own,"
      And the email should contain "newuser"
      And the email should contain "Please activate your account"
    
    # user activates account
    When all emails have been delivered
      And I click the first link in the email
    When I am logged in as "newuser" with password "password1"
    Then I should see "Successfully logged in."
