@admin
Feature: Invite requests

  Scenario: Request an invite for a friend
    Given I have no users
      And I have an AdminSetting
      And the following admin exists
      | login       | password   | email                    |
      | admin-sam   | password   | test@archiveofourown.org |
      And the following activated user exists
      | login  | password |
      | user1  | password |
    
    # user requests invites
    When I am logged in as "user1" with password "password"
      And I go to the homepage
    Then I should see "INVITE A FRIEND"
    When I follow "INVITE A FRIEND"
    Then I should see "Invite a friend"
      And I should see "Sorry, you have no unsent invitations right now."
    When I go to user1's user page
      And I follow "Invitations"
    Then I should see "Invite a friend"
      And I should see "Sorry, you have no unsent invitations right now."
    When I follow "Request more"
    Then I should see "How many invites are you requesting?"
    When I fill in "user_invite_request_quantity" with "3"
      And I fill in "user_invite_request_reason" with "I want them for a friend"
      And I press "Create"
    Then I should see "Request was successfully created."
    When I follow "Invitations"
    Then I should see "Sorry, you have no unsent invitations right now."
    
    # admin grants request
    When I follow "Log out"
    When I go to the admin_login page
      And I fill in "admin_login" with "admin-sam"
      And I fill in "admin_password" with "password"
      And I press "Log in as admin"
    Then I should see "Logged in successfully"
    When I follow "invitations"
      And I follow "Manage requests"
    Then I should see "user1"
      And I should see "3"
      And I should see "I want them for a friend"
    When I fill in "requests[user1]" with "2"
      And I press "Update"
    Then I should see "Requests were successfully updated."
    
    # user sees them
    When I follow "Log out"
    Then I should see "You have been logged out"
    When I am logged in as "user1" with password "password"
      And I go to user1's user page
      And I follow "Invitations"
    Then I should see "Invite a friend"
      And I should not see "Sorry, you have no unsent invitations right now."
      And I should see "You have 2 open invitations and 0 that have been sent but not yet used."
    When all emails have been delivered
      And I fill in "Email address" with "test@archiveofourown.org"
      And I press "Send invite"
    Then 1 email should be delivered
