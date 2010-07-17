@admin
Feature: Invite queue management

  Scenario: Turn on queue, join queue and check status
    Given I have no users
      And I have an AdminSetting
      And the following admin exists
      | login       | password   | email                    |
      | admin-sam   | password   | test@archiveofourown.org |
    When I go to the admin_login page
      And I fill in "admin_login" with "admin-sam"
      And I fill in "admin_password" with "password"
      And I press "Log in as admin"
    Then I should see "Logged in successfully"
    When I follow "settings"
      And I check "admin_setting_invite_from_queue_enabled"
      And I press "Update"
    Then I should see "Archive settings were successfully updated"
    When I follow "Log out"
    Then I should see "You have been logged out"
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
    When I fill in "email" with "test@archiveofourown.org"
      And I press "Go"
    Then I should see "Invitation Status for test@archiveofourown.org"
      And I should see "You are currently number 1 on our waiting list! At our current rate, you should receive an invitation on or around"
    When the invite_from_queue_at is yesterday
    And the check_queue rake task is run
    Then 1 email should be delivered
    When I am on the invite_requests page
      And I fill in "email" with "test@archiveofourown.org"
      And I press "Go"
    Then I should see "Sorry, we couldn't find that address in our queue."
