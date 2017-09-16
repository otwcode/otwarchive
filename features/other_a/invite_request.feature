@admin
Feature: Invite requests

  Scenario: Request an invite for a friend

    Given invitations are required
      And I am logged in as "user1"
    When I try to invite a friend from my user page
      And I follow "Request invitations"
    When I fill in "user_invite_request_quantity" with "3"
      And I fill in "user_invite_request_reason" with "I want them for a friend"
      And I press "Send Request"
    Then I should see a create confirmation message

  Scenario: Requests are not instantly granted

    Given invitations are required
      And I am logged in as "user1"
      And I request some invites
    When I follow "Invitations"
      Then I should see "Sorry, you have no unsent invitations right now."

  Scenario: Admin sees the request

    Given invitations are required
      And I am logged in as "user1"
      And I request some invites
    When I view requests as an admin
    Then I should see "user1"
      And the "requests[user1]" field should contain "3"
      And I should see "I want them for a friend"

  Scenario: Admin can refuse request

    Given invitations are required
      And I am logged in as "user1"
      And I request some invites
    When I view requests as an admin
      And I fill in "requests[user1]" with "0"
      And I press "Update"
    Then I should see "Requests were successfully updated."
      And I should not see "user1"

  Scenario: Admin can grant request

    Given invitations are required
      And I am logged in as "user1"
      And I request some invites
    When I view requests as an admin
      And I fill in "requests[user1]" with "2"
      And I press "Update"
    Then I should see "Requests were successfully updated."

  Scenario: User is granted invites

    Given invitations are required
      And I am logged in as "user1"
      And I request some invites
      And an admin grants the request
    When I try to invite a friend from my user page
    Then I should see "Invite a friend"
      And I should not see "Sorry, you have no unsent invitations right now."
      And I should see "You have 2 open invitations and 0 that have been sent but not yet used."

  Scenario: User can send out invites they have been granted, and the recipient can sign up

    Given invitations are required
      And I am logged in as "user1"
      And I request some invites
      And an admin grants the request
      And I try to invite a friend from my user page
    When all emails have been delivered
      And I fill in "Email address" with "test@archiveofourown.org"
      And I press "Send Invitation"
    Then 1 email should be delivered to test@archiveofourown.org
      And the email should contain "has invited you to join our beta!"

    Given I am a visitor
    When I click the first link in the email
      And I fill in the sign up form with valid data
      And I fill in the following:
        | user_login                  | user2     |
        | user_password               | password1 |
        | user_password_confirmation  | password1 |
      And I press "Create Account"
    Then I should see "Within 24 hours, you should receive an email at the address you gave us."
      And I should see how long I have to activate my account
      And I should see "If you don't hear from us within 24 hours"

  Scenario: When not logged in, there is a Create an Account button
  when account creation is enabled and invitations are not required

    Given account creation does not require an invitation
      And I am a visitor
    When I go to the homepage
      And I should see "Create an Account!"

  Scenario: When not logged in, there is a Get Invited! button
    when account creation requires an invitation

    Given account creation requires an invitation
      And I am a visitor
    When I go to the homepage
    Then I should see "Get Invited!"

  Scenario: When not logged in, there is no Get Invited! or Create an Account! button when account creation is disabled

    Given account creation is disabled
      And I am a visitor
    When I go to the homepage
    Then I should not see "Get Invited!"
      And I should not see "Create an Account!"

  Scenario: Banned users cannot access their invitations page

    Given I am logged in as a banned user
    When I go to my invitations page
    Then I should be on my user page
    And I should see "Your account has been banned."

  Scenario:  A user can manage their invitations

    Given I am logged in as "user1"
      And "user1" has "5" invitations
    When I go to my user page
     And I follow "Invitations"
     And I follow "Manage Invitations"
    Then I should see "Unsent (5)"
    When I follow "Unsent (5)"
    Then I should see "Unsent (5)"
    When I follow the link for "user1" first invite
    Then I should see "Enter an email address"
    When I fill in "invitation[invitee_email]" with "user6@example.org"
      And I press "Update Invitation"
    Then I should see "Invitation was successfully sent."

  Scenario: An admin can create a user's invitations
    Given I am logged in as an admin
      And the user "steven" exists and is activated
    When I go to steven's invitations page
    Then I should see "Create more invitations for this user"
    When I fill in "invitation[number_of_invites]" with "4"
     And press "Create"
    Then I should see "Invitations were successfully created."

  Scenario: An admin can delete a user's invitations
    Given the user "user1" exists and is activated
      And "user1" has "5" invitations
      And I am logged in as an admin
    When I follow "Invite New Users"
      And I fill in "invitation[user_name]" with "user1"
      And I press "Go"
    Then I should see "Token"
    When I follow "Delete"
    Then I should see "Invitation successfully destroyed"
      And "user1" should have "4" invitations
