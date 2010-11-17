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
      And I fill in "admin_session_login" with "admin-sam"
      And I fill in "admin_session_password" with "password"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"
    When I follow "invitations"
      And I follow "Manage requests"
    Then I should see "user1"
      And the "requests[user1]" field should contain "3"
      And I should see "I want them for a friend"
    When I fill in "requests[user1]" with "2"
      And I press "Update"
    Then I should see "Requests were successfully updated."
    
    # user sees them
    When I follow "Log out"
    Then I should see "Successfully logged out"
    When I am logged in as "user1" with password "password"
      And I go to user1's user page
      And I follow "Invitations"
    Then I should see "Invite a friend"
      And I should not see "Sorry, you have no unsent invitations right now."
      And I should see "You have 2 open invitations and 0 that have been sent but not yet used."
    When all emails have been delivered
      And I fill in "Email address" with "test@archiveofourown.org"
      And I press "Send invite"
    Then 1 email should be delivered to test@archiveofourown.org
      And the email should contain "user1 has invited you to join our beta!"
    When I follow "Log out"
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
