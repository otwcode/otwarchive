@admin
Feature: Admin tasks

  Scenario: Log in as an admin and do admin-y things. Wrong password fails admin login, you can find users, post a new FAQ section.

    Given I have no users
      And the following admin exists
      | login       | password |
      | Zooey       | secret   |
      And the following activated user exists
      | login       | password      |
      | dizmo       | wrangulator   |
      And I have loaded the "roles" fixture

    # admin cannot log in as an ordinary user - it is a different type of account

    When I go to the home page
      And I fill in "user_session_login" with "Zooey"
      And I fill in "user_session_password" with "secret"
      And I press "Log in"
    Then I should see "We couldn't find that user name in our database. Please try again"

    # FAQs have not yet been posted

    When I go to the archive_faqs page
    Then I should see "Some commonly asked questions about the Archive are answered here"
      And I should not see "Some text"

    # Login as an admin

    When I go to the admin_login page
      And I fill in "admin_session_login" with "dizmo"
      And I fill in "admin_session_password" with "wrangulator"
      And I press "Log in as admin"
    Then I should see "Authentication failed"
    When I go to the admin_login page
      And I fill in "admin_session_login" with "Zooey"
      And I fill in "admin_session_password" with "secret"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"

    # search for a user

    When I fill in "query" with "dizmo"
      And I press "Find"
    Then I should see "dizmo" within "#admin_users_table"
    When I fill in "user_email" with "dizmo@fake.com"
      And I press "Update"
    Then the "user_email" field should contain "dizmo@fake.com"

    # Adding and removing roles
    When I check "user_roles_1"
      And I press "Update"
    # Then show me the page
    Then I should see "User was successfully updated"
      And the "user_roles_1" checkbox should be checked
    When I uncheck "user_roles_1"
      And I press "Update"
    Then I should see "User was successfully updated"
      And the "user_roles_1" checkbox should not be checked

    # add a new section to the FAQ

    When I follow "admin posts"
      And I follow "Archive FAQ" within "#main"
      And I should not see "Some text"
    When I follow "Add a new section"
      And I fill in "content" with "Some text, that is sufficiently long to pass validation."
      And I fill in "title" with "New subsection"
    When I press "Post"
    Then I should see "ArchiveFaq was successfully created"
    When I go to the archive_faqs page
      And I follow "New subsection"
    Then I should see "Some text, that is sufficiently long to pass validation" within ".userstuff"

  Scenario: Change some admin settings for performance - guest downloading and tag wrangling

  Given I have no users
    And the following admin exists
      | login       | password |
      | Zooey       | secret   |
    And the following activated tag wrangler exists
      | login       | password      |
      | dizmo       | wrangulator   |
    And a character exists with name: "Ianto Jones", canonical: true

  # post a work and download it as a guest

  When I am logged in as "dizmo" with password "wrangulator"
    And I post the work "Storytime"
    And I follow "Log out"
    And I view the work "Storytime"
  Then I should see "Download"

  # turn off guest downloading

  When I go to the admin_login page
    And I fill in "admin_session_login" with "Zooey"
    And I fill in "admin_session_password" with "secret"
    And I press "Log in as admin"
  Then I should see "Successfully logged in"
  When I follow "settings"
  Then I should see "Turn off downloading for guests"
    And I should see "Turn off tag wrangling for non-admins"
  When I check "Turn off downloading for guests"
    And I press "Update"
  Then I should see "Archive settings were successfully updated."

  # Check guest downloading is off

  When I follow "Log out"
  Then I should see "Successfully logged out"
  When I view the work "Storytime"
    And I follow "MOBI"
  Then I should see "Due to current high load"

  # Turn off tag wrangling

  When I go to the admin_login page
    And I fill in "admin_session_login" with "Zooey"
    And I fill in "admin_session_password" with "secret"
    And I press "Log in as admin"
  Then I should see "Successfully logged in"
  When I follow "settings"
    And I check "Turn off tag wrangling for non-admins"
    And I press "Update"
  Then I should see "Archive settings were successfully updated."

  # Check tag wrangling is off

  When I follow "Log out"
  Then I should see "Successfully logged out"
  When I am logged in as "dizmo" with password "wrangulator"
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
    And I am on my user page
    And I follow "Profile"
  Then I should see "Set My Preferences"
  When I follow "Set My Preferences"
  Then I should see "Update My Preferences"
  When I check "Turn off admin notification emails"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I follow "Log out"
  Then I should see "Successfully logged out"

  # admin sends out notice to all users

  When I go to the admin_login page
    And I fill in "Admin user name" with "Zooey"
    And I fill in "admin_session_password" with "secret"
    And I press "Log in as admin"
  Then I should see "Successfully logged in"
  When I follow "notices"
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
    And the email should contain "Dear enigel"
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
    And I press "Add Comment"
  Then I should see "Comment created!"
  When I am logged out

  # comment from registered user cannot be marked as spam.
  # If registered user is spamming, this goes to Abuse team as ToS violation
  When I am logged in as an admin
  Then I should see "Successfully logged in"
  When I view the work "The One Where Neal is Awesome"
    And I follow "Read Comments (1)"
  Then I should not see "Mark as spam"

  # now mark a comment as spam
  When I post the comment "Would you like a genuine rolex" on the work "The One Where Neal is Awesome" as a guest
    And I am logged in as an admin
    And I view the work "The One Where Neal is Awesome"
    And I follow "Read Comments (2)"
  Then I should see "rolex"
    And I should see "Spam"
  When I follow "Spam"
  Then I should not see "rolex"
  When I follow "Hide Comments"
  # TODO: Figure out if this is a defect or not, that it shows 2 instead of 1
  # Then I should see "Read Comments (1)"

  # comment should no longer be there
  When I follow "Read Comments"
  Then I should not see "rolex"
  When I am logged out as an admin
    And I view the work "The One Where Neal is Awesome"
    And I follow "Read Comments"
  Then I should not see "rolex"
  When I am logged in as "author" with password "password"
    And I view the work "The One Where Neal is Awesome"
    And I follow "Read Comments"
    And "Issue 2213" is fixed
  # Then I should not see "rolex"

  Scenario: make an admin post and receive comment notifications for comments posted to it
  
  # admin makes post
  Given I am logged in as an admin
    And I make an admin post
    
  # regular user replies to admin post
  When I am logged out as an admin
    And I am logged in as a random user
    And I go to the admin-posts page
  Given all emails have been delivered    
  When I follow "Add Comment"
    And I fill in "Comment" with "Excellent, my dear!"
    And I press "Add Comment"
  Then 1 email should be delivered to "testadmin@example.org"

  # admin replies to comment of regular user
  Given I am logged out
    And I am logged in as an admin
    And I go to the admin-posts page
    And I follow "Default Admin Post"
  Given all emails have been delivered    
  When I follow "Read Comments (1)"
    And I follow "Reply"
    And I fill in "Comment" with "Thank you very much!" within ".odd"
    And I press "Add Comment" within ".odd"
  Then I should see "Comment created"
  # admin gets notified of their own comment, this is not a bug unless:
  # TODO: comments should be able to belong to an admin officially, otherwise someone can spoof being an admin by using the admin name and email
    And 1 email should be delivered to "testadmin@example.org"
  
  # regular user replies to comment of admin
  Given I am logged out as an admin
    And I am logged in as a random user
    And I go to the admin-posts page
  Given all emails have been delivered    
  When I follow "Read 2 Comments"
    And I follow "Reply" within ".even"
    And I fill in "Comment" with "Oh, don't grow too big a head, you." within ".even"
    And I press "Add Comment" within ".even"
  # admin gets the user's reply twice, this is not a bug unless TODO above is fixed
  Then 2 emails should be delivered to "testadmin@example.org"
  
  # regular user edits their comment
  Given all emails have been delivered    
  When I follow "Edit"
    And I press "Update"
  Then 2 emails should be delivered to "testadmin@example.org"
  
  Scenario: admin goes to the Support page
  
  Given I am logged in as an admin
  When I go to the support page
  Then I should see "Support and Feedback"
    And I should see "testadmin@example.org" in the "feedback_email" input

