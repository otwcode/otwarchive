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
    
    # TODO: change the status of a user, to and from tag wrangler, translator, etc.
    
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
  
  Scenario: Send out an admin notice to all users
  
  Given I have no users
    And the following admin exists
      | login       | password |
      | Zooey       | secret   |
    And the following activated user exists
      | login       | password             |
      | enigel      | emailnotifications   |
      | otherfan    | hatesnotifications   |
    And all emails have been delivered
  
  # otherfan turns off notifications
  
  When I am logged in as "otherfan" with password "hatesnotifications"
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
    And the system processes jobs
  # confirmation email to admin, and to one user
  Then 2 emails should be delivered
    And the email should not contain "otherfan"
    And the email should contain "enigel"
    And "Issue 2035" is fixed
    # And the email should contain "Hey, we did stuff"
    And the email should contain "And it was awesome"
