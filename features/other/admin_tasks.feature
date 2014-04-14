@admin
Feature: Admin tasks

  Scenario: admin cannot log in as an ordinary user - it is a different type of account
  
  Given the following admin exists
      | login       | password |
      | Zooey       | secret   |
  When I go to the home page
      And I fill in "user_session_login" with "Zooey"
      And I fill in "user_session_password" with "secret"
      And I press "Log In"
    Then I should see "The password or user name you entered doesn't match our records"
    
  Scenario: Ordinary user cannot log in as admin
  
  Given the following activated user exists
      | login       | password      |
      | dizmo       | wrangulator   |
      And I have loaded the "roles" fixture
  
  When I go to the admin_login page
      And I fill in "admin_session_login" with "dizmo"
      And I fill in "admin_session_password" with "wrangulator"
      And I press "Log in as admin"
    Then I should see "Authentication failed"
    
  Scenario: Admin can log in
  
  Given I have no users
      And the following admin exists
      | login       | password |
      | Zooey       | secret   |
      And I have loaded the "roles" fixture
    When I go to the admin_login page
      And I fill in "admin_session_login" with "Zooey"
      And I fill in "admin_session_password" with "secret"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"
  
  Scenario: admin can find users
  
  Given I am logged in as "someone"
    And I have loaded the "roles" fixture
    When I am logged in as an admin
      And I fill in "query" with "someone"
      And I press "Find"
    Then I should see "someone" within "#admin_users_table"
    
  Scenario: Post a FAQ
  
    When I go to the archive_faqs page
    Then I should see "Some commonly asked questions about the Archive are answered here"
      And I should not see "Some text"
    When I am logged in as an admin
    When I follow "Admin Posts"
      And I follow "Archive FAQ" within "#main"
      And I should not see "Some text"
    When I follow "New FAQ Section"
      And I fill in "content" with "Some text, that is sufficiently long to pass validation."
      And I fill in "title" with "New subsection"
    When I press "Post"
    Then I should see "ArchiveFaq was successfully created"
    When I go to the archive_faqs page
      And I follow "New subsection"
    Then I should see "Some text, that is sufficiently long to pass validation" within ".userstuff"
    
  Scenario: Edit FAQ
  
  Given I have posted a FAQ
  When I follow "Admin Posts"
    And I follow "Archive FAQ" within "#main"
    And I follow "Edit"
    And I fill in "content" with "Number 1 posted FAQ, this is, and Yoda approves."
    And I press "Post"
  Then I should see "ArchiveFaq was successfully updated"
    And I should see "Yoda approves"

  Scenario: Find users

    Given the following activated user exists
      | login       | password      |
      | dizmo       | wrangulator   |
      And I have loaded the "roles" fixture
    When I am logged in as an admin

    # change user email

    When I fill in "query" with "dizmo"
      And I press "Find"
    Then I should see "dizmo" within "#admin_users_table"
    When I fill in "user_email" with "dizmo@fake.com"
      And I press "Update"
    Then the "user_email" field should contain "dizmo@fake.com"

    # Adding and removing roles
    When I check "user_roles_1"
      And I press "Update"
    # Then show me the html
    Then I should see "User was successfully updated"
      And the "user_roles_1" checkbox should be checked
    When I uncheck "user_roles_1"
      And I press "Update"
    Then I should see "User was successfully updated"
      And the "user_roles_1" checkbox should not be checked

  Scenario: Change some admin settings for performance - guest downloading and tag wrangling

  Given the following activated tag wrangler exists
      | login           |
      | dizmo           |
    And a character exists with name: "Ianto Jones", canonical: true

  # post a work and download it as a guest

  When I am logged in as "dizmo"
    And I post the work "Storytime"
    And I log out
    And I view the work "Storytime"
  Then I should see "Download"

  # turn off guest downloading

  When I am logged in as an admin
  When I follow "Settings"
  Then I should see "Turn off downloading for guests"
    And I should see "Turn off tag wrangling for non-admins"
  When I check "Turn off downloading for guests"
    And I press "Update"
  Then I should see "Setting banner back on for all users. This may take some time"
  # Changing from null to empty string counts as a change to the banner

  # Check guest downloading is off

  When I log out
  Then I should see "Successfully logged out"
  When I view the work "Storytime"
    And I follow "MOBI"
  Then I should see "Due to current high load"

  # Turn off tag wrangling

  When I am logged in as an admin
  When I follow "Settings"
    And I check "Turn off tag wrangling for non-admins"
    And I press "Update"
  Then I should see "Archive settings were successfully updated."

  # Check tag wrangling is off

  When I log out
  Then I should see "Successfully logged out"
  When I am logged in as "dizmo"
    And I edit the tag "Ianto Jones"
  Then I should see "Wrangling is disabled at the moment. Please check back later."
    And I should not see "Synonym of"

  # Set them back to normal
  Given I am logged out
  Given guest downloading is on
  Given I am logged out as an admin
  Given tag wrangling is on

  Scenario: Send out an admin notice to all users

  Given I have no users
    And the following admin exists
      | login       | password |
      | Zooey       | secret   |
    And the following activated user exists
      | login       | password             | email   |
      | enigel      | emailnotifications   | e@e.org |
      | otherfan    | hatesnotifications   | o@e.org |
    And all emails have been delivered

  # otherfan turns off notifications

  When I am logged in as "otherfan" with password "hatesnotifications"
    And I go to my preferences page
    And I check "Turn off admin emails"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"

  # admin sends out notice to all users

  When I am logged in as an admin
    And I go to the admin-notices page
    And I fill in "Subject" with "Hey, we did stuff"
    And I fill in "Message" with "And it was awesome"
    And I check "Notify All Users"
    And I press "Send Notification"
  Then 1 email should be delivered to webmaster@example.org
    And the email should not contain "otherfan"
    And the email should contain "enigel"
  When the system processes jobs
  # confirmation email to admin, and to one user
  Then 1 email should be delivered to e@e.org
    # Hack for HTML emails. 'Enigel' is a link the new mailers, tests not catching that
    And the email should contain "Dear"
    And the email should contain "enigel"
    And "Issue 2035" is fixed
    # And the email should contain "Hey, we did stuff"
    And the email should contain "And it was awesome"

  Scenario: Mark a comment as spam

  Given I have no works or comments
    And the following activated users exist
    | login         | password   |
    | author        | password   |
    | commenter     | password   |
    And the following admin exists
      | login       | password |
      | Zooey       | secret   |

  # set up a work with a genuine comment

  When I am logged in as "author" with password "password"
    And I post the work "The One Where Neal is Awesome"
  When I am logged out
    And I am logged in as "commenter" with password "password"
    And I view the work "The One Where Neal is Awesome"
    And I fill in "Comment" with "I loved this!"
    And I press "Comment"
  Then I should see "Comment created!"
  When I am logged out

  # comment from registered user cannot be marked as spam.
  # If registered user is spamming, this goes to Abuse team as ToS violation
  When I am logged in as an admin
  Then I should see "Successfully logged in"
  When I view the work "The One Where Neal is Awesome"
    And I follow "Comments (1)"
  Then I should not see "Mark as spam"

  # now mark a comment as spam
  When I post the comment "Would you like a genuine rolex" on the work "The One Where Neal is Awesome" as a guest
    And I am logged in as an admin
    And I view the work "The One Where Neal is Awesome"
    And I follow "Comments (2)"
  Then I should see "rolex"
    And I should see "Spam"
  When I follow "Spam"
  Then I should see "Not Spam"
  When I follow "Hide Comments"
  # TODO: Figure out if this is a defect or not, that it shows 2 instead of 1
  # Then I should see "Comments (1)"

  # comment should no longer be there
  When I follow "Comments"
  Then I should see "rolex"
    And I should see "Not Spam"
  When I am logged out as an admin
    And I view the work "The One Where Neal is Awesome"
    And I follow "Comments"
  Then I should not see "rolex"
  When I am logged in as "author" with password "password"
    And I view the work "The One Where Neal is Awesome"
    And I follow "Comments"
    Then I should not see "rolex"

  Scenario: admin goes to the Support page
  
  Given I am logged in as an admin
  When I go to the support page
  Then I should see "Support and Feedback"
    And I should see "testadmin@example.org" in the "feedback_email" input
    
  Scenario: Post known issues
  
  When I am logged in as an admin
    And I follow "Admin Posts"
    And I follow "Known Issues" within "#main"
    And I follow "make a new known issues post"
    And I fill in "known_issue_title" with "First known problem"
    And I fill in "content" with "This is a bit of a problem"
    # Suspect related to issue 2458
    And I press "Post"
  Then I should see "KnownIssue was successfully created"
  
  Scenario: Edit known issues
  
  # TODO
  Given I have posted known issues
  When I edit known issues
  Then I should see "KnownIssue was successfully updated"

  Scenario: Admin can set invite from queue number to a number greater than or equal to 1

    Given I am logged in as an admin
    And I go to the admin-settings page
    And I fill in "admin_setting_invite_from_queue_number" with "0"
    And I press "Update"
    Then I should see "Invite from queue number must be greater than 0. To disable invites, uncheck the appropriate setting."
    When I fill in "admin_setting_invite_from_queue_number" with "1"
    And I press "Update"
    Then I should not see "Invite from queue number must be greater than 0."