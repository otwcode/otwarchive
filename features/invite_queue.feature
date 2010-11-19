@admin
Feature: Invite queue management

  Scenario: Turn on queue, join queue and check status
    Given I have no users
      And I have an AdminSetting
      And the following admin exists
      | login       | password   | email                    |
      | admin-sam   | password   | test@archiveofourown.org |
      And the following users exist
      | login | password |
      | user1 | password |
    
    # turn on queue
    When I go to the admin_login page
      And I fill in "admin_session_login" with "admin-sam"
      And I fill in "admin_session_password" with "password"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"
    When I follow "settings"
      And I check "admin_setting_invite_from_queue_enabled"
      And I press "Update"
    Then I should see "Archive settings were successfully updated"
    When I follow "Log out"
    Then I should see "Successfully logged out"
    
    # join the queue
    When I am on the homepage
      And all emails have been delivered
      And I follow "SIGN UP NOW"
    Then I should see "Request an invite"
    When I fill in "invite_request_email" with "test@archiveofourown.org"
      And I press "Add me to the list"
    Then I should see "You've been added to our queue"
    When I am on the homepage
      And I follow "SIGN UP NOW"
    Then I should see "Request an invite"
    
    # check your place in the queue - invalid address
    When I fill in "email" with "testttt@archiveofourown.org"
      And I press "Go"
    Then I should see "Sorry, we couldn't find that address in our queue"
      And I should not see "You are currently number"
    
    # check your place in the queue - correct address
    When I fill in "email" with "test@archiveofourown.org"
      And I press "Go"
    Then I should see "Invitation Status for test@archiveofourown.org"
      And I should see "You are currently number 1 on our waiting list! At our current rate, you should receive an invitation on or around"
    
    # queue sends out invites
    When the invite_from_queue_at is yesterday
    And the check_queue rake task is run
    Then 1 email should be delivered to test@archiveofourown.org
    When I am on the invite_requests page
      And I fill in "email" with "test@archiveofourown.org"
      And I press "Go"
    Then I should see "Sorry, we couldn't find that address in our queue."
    
    # invite can be used
    When I go to the admin_login page
      And I fill in "admin_session_login" with "admin-sam"
      And I fill in "admin_session_password" with "password"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"
    When I follow "invitations"
      And I fill in "invitee_email" with "test@archiveofourown.org"
      And I press "Go"
    Then I should see "Sender queue"
      And I should see "copy and use"
    When I follow "copy and use"
    Then I should see "You are already logged in!"
    When I follow "Log out"
    
    # user uses email invite
    Then the email should contain "You've been invited to join our beta!"
    
    # user creates account, with error messages
    When I click the first link in the email
      And I fill in "user_login" with "user1"
      And I fill in "user_password" with "pass"
      And I press "Create Account"
    Then I should see "Login has already been taken"
      And I should see "Password is too short (minimum is 6 characters)"
      And I should see "Password doesn't match confirmation"
      And I should see "Sorry, you need to accept the Terms of Service in order to sign up."
      And I should see "Sorry, you have to be over 13!"
      And I should not see "Email address is too short"
    When I fill in "user_login" with "newuser"
      And I fill in "user_password" with "password1"
      And I fill in "user_password_confirmation" with "password1"
      And I check "user_age_over_13"
      And I check "user_terms_of_service"
      And I fill in "user_email" with ""
      And I press "Create Account"
    Then I should see "Email does not seem to be a valid address."
    When I fill in "user_email" with "fake@fake@fake"
      And I press "Create Account"
    Then I should see "Email does not seem to be a valid address."
    When I fill in "user_email" with "test@archiveofourown.org"
      And all emails have been delivered
    When I press "Create Account"
    Then I should see "Account Created!"
    Then 1 email should be delivered
      And the email should contain "Welcome to the Archive of Our Own, newuser!"
      And the email should contain "Please activate your account"
    
    # user activates account
    When all emails have been delivered
      And I click the first link in the email
    Then 1 email should be delivered
      And the email should contain "your account has been activated"
      And I should see "Please log in"
    When I fill in "user_session_login" with "newuser"
      And I fill in "user_session_password" with "password1"
      And I press "Log in"
    Then I should see "Successfully logged in"
