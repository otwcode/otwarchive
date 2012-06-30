@admin
Feature: Invite requests

  Scenario: Can't invite a friend from the homepage if you don't have any invitations

    Given I have invitations set up
    When I try to invite a friend from the homepage
    Then I should see "Invite a friend"
      And I should see "Sorry, you have no unsent invitations right now."

  Scenario: Can't invite a friend from your user page if you don't have any invitations

    Given I have invitations set up
    When I try to invite a friend from my user page
    Then I should see "Invite a friend"
      And I should see "Sorry, you have no unsent invitations right now."

@wip
  Scenario: Request an invite for a friend

    Given I have invitations set up
    When I try to invite a friend from my user page
      And I follow "Request more"
    When I fill in "user_invite_request_quantity" with "3"
      And I fill in "user_invite_request_reason" with "I want them for a friend"
      And I press "Send Request"
    Then I should see a create confirmation message

@wip
  Scenario: Requests are not instantly granted

    Given I have invitations set up
    When I request some invites
    When I follow "Invitations"
    Then I should see "Sorry, you have no unsent invitations right now."

@wip
  Scenario: Admin sees the request

    Given I have invitations set up
    When I request some invites
    When I view requests as an admin
    Then I should see "user1"
      And the "requests[user1]" field should contain "3"
      And I should see "I want them for a friend"

@wip
  Scenario: Admin can refuse request

    Given I have invitations set up
    When I request some invites
    When I view requests as an admin
    When I fill in "requests[user1]" with "0"
      And I press "Update"
    Then I should see "Requests were successfully updated."
      And I should not see "user1"

@wip
  Scenario: Admin can grant request

    Given I have invitations set up
    When I request some invites
    When I view requests as an admin
    When I fill in "requests[user1]" with "2"
      And I press "Update"
    Then I should see "Requests were successfully updated."

@wip
  Scenario: User is granted invites

    Given I have invitations set up
    When I request some invites
    When an admin grants the request
    When I try to invite a friend from my user page
    Then I should see "Invite a friend"
      And I should not see "Sorry, you have no unsent invitations right now."
      And I should see "You have 2 open invitations and 0 that have been sent but not yet used."

@wip
  Scenario: User can send out invites they have been granted

    Given I have invitations set up
    When I request some invites
    When an admin grants the request
    When I try to invite a friend from my user page
    When all emails have been delivered
      And I fill in "Email address" with "test@archiveofourown.org"
      And I press "Send invite"
    Then 1 email should be delivered to test@archiveofourown.org
      And the email should contain "user1 has invited you to join our beta!"
    When I log out
    Then I should see "Sorry, you don't have permission to access the page you were trying to reach. Please log in."
    
    # user uses invite
    When I click the first link in the email
      And I fill in "user_login" with "user2"
      And I fill in "user_password" with "password1"
      And I fill in "user_password_confirmation" with "password1"
      And I check "user_age_over_13"
      And I check "user_terms_of_service"
      And I press "Create Account"
    Then I should see "In just a few minutes, you should receive an email"
      And I should see "You must verify your account within 14 days"
      And I should see "If you don't hear from us within two hours"
