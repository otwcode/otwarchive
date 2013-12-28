@admin
Feature: Invite queue management

  Scenario: Can turn queue off and it displays as off
  
  When I turn off the invitation queue
  Then I should see "Setting banner back on for all users. This may take some time"
  # Changing from null to empty string counts as a change to the banner
  When I am logged out as an admin
  When I am on the homepage
  Then I should not see "Get an Invite"
    And I should see "Archive of Our Own"
    And This is the end of the scenario
  
  Scenario: Can turn queue on and it displays as on
  
  When I turn on the invitation queue
  When I am logged out as an admin
  When I am on the homepage
  Then I should see "Get an Invite"
  When I follow "Get an Invite"
  Then I should see "Request an invite"

  Scenario: Join queue and check status
    Given I have no users
      And I have an AdminSetting
      And the following admin exists
      | login       | password   | email                    |
      | admin-sam   | password   | test@archiveofourown.org |
      And the following users exist
      | login | password |
      | user1 | password |
    
    # join queue
    When I turn on the invitation queue
    When I am on the homepage
      And all emails have been delivered
      And I follow "Get an Invite"
      And I should see "We are sending out 10 invitations per day."
    When I fill in "invite_request_email" with "test@archiveofourown.org"
      And I press "Add me to the list"
    Then I should see "You've been added to our queue"
    
    # check your place in the queue - invalid address
    When I am on the homepage
      And I follow "Get an Invite"
    When I fill in "email" with "testttt@archiveofourown.org"
      And I press "Go"
    Then I should see "You can search for the email address you signed up with below."
      And I should see "If you can't find it, your invitation may have already been emailed to that address; please check your email Spam folder as your spam filters may have placed it there."
    # Then I should see "Sorry, we can't find the email address you entered."
      And I should not see "You are currently number"
    
    # check your place in the queue - correct address
    When I fill in "email" with "test@archiveofourown.org"
      And I press "Go"
    Then I should see "Invitation Status for test@archiveofourown.org"
      And I should see "You are currently number 1 on our waiting list! At our current rate, you should receive an invitation on or around"

  Scenario: Can't add yourself to the queue when queue is off
  
  When I turn off the invitation queue
  When I am logged out as an admin
  When I go to the invite_requests page
  Then I should not see "Add yourself to the list"
    And I should not find "invite_request_email"
  
  Scenario: Can still check status when queue is off
  
  When I turn off the invitation queue
  When I am logged out as an admin
  When I go to the invite_requests page
  Then I should see "Wondering how long you'll have to wait"
    And I should find "email"
  
  Scenario: queue sends out invites
  
    Given I have no users
      And I have an AdminSetting
      And the following admin exists
      | login       | password   | email                    |
      | admin-sam   | password   | test@archiveofourown.org |
      And the following users exist
      | login | password |
      | user1 | password |
    
    # join queue
    When I turn on the invitation queue
    When I am on the homepage
      And all emails have been delivered
      And I follow "Get an Invite"
    When I fill in "invite_request_email" with "test@archiveofourown.org"
      And I press "Add me to the list"
    When the invite_from_queue_at is yesterday
    And the check_queue rake task is run
    Then 1 email should be delivered to test@archiveofourown.org
    When I am on the invite_requests page
      And I fill in "email" with "test@archiveofourown.org"
      And I press "Go"
    # Then I should see "Sorry, we can't find the email address you entered."
    Then I should see "You can search for the email address you signed up with below."
      And I should see "If you can't find it, your invitation may have already been emailed to that address; please check your email Spam folder as your spam filters may have placed it there."
    
    # invite can be used
    When I go to the admin_login page
      And I fill in "admin_session_login" with "admin-sam"
      And I fill in "admin_session_password" with "password"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"
    When I follow "Invitations"
      And I fill in "invitee_email" with "test@archiveofourown.org"
      And I press "Go"
    Then I should see "Sender queue"
      And I should see "copy and use"
    When I follow "copy and use"
    Then I should see "You are already logged in!"
    When I log out
    
    # user uses email invite
    Then the email should contain "You've been invited to join our beta!"
      And the email should contain "fanart"
      And the email should contain "podfic"
