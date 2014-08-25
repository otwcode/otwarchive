@admin
Feature: Invite requests

  Scenario: Can't invite a friend from the homepage if you don't have any invitations

    Given invitations are required
      And I am logged in as "user1"
    When I try to invite a friend from the homepage
    Then I should see "Invite a friend"
      And I should see "Sorry, you have no unsent invitations right now."

  Scenario: Request an invite for a friend

    Given invitations are required
      And I am logged in as "user1"
    When I try to invite a friend from my user page
      And I follow "Request more"
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
      And I press "Send invite"
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
      And I should see "You must verify your account within 14 days"
      And I should see "If you don't hear from us within 24 hours"

  Scenario: When logged in, there is no Invite a Friend button when invitations are not required

    Given account creation does not require an invitation
      And I am logged in
    When I go to the homepage
      Then I should not see "Invite a Friend"

  Scenario: When logged in, there is an Invite a Friend button when invitations are required

    Given account creation requires an invitation
      And I am logged in
    When I go to the homepage
      Then I should see "Invite a Friend"

  Scenario: When not logged in, there is both a Log In and a Create an Account button
    when account creation is enabled and invitations are not required

    Given account creation does not require an invitation
      And I am a visitor
    When I go to the homepage
      Then I should not see "Invite a Friend"
      And I should see "Create an Account"
      And I should see "Log In"

  Scenario: When not logged in, there is both a Log In and a Get an Invite button
    when account creation requires an invitation

    Given account creation requires an invitation
      And I am a visitor
    When I go to the homepage
    Then I should not see "Invite a Friend"
      And I should see "Get an Invite"
      And I should see "Log In"

  Scenario: When not logged in, there is only a Log In button when account creation is disabled

    Given account creation is disabled
      And I am a visitor
    When I go to the homepage
    Then I should not see "Invite a Friend"
      And I should not see "Get an Invite"
      And I should not see "Create an Account"
      And I should see "Log In"
