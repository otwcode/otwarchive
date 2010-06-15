@users
Feature: Admin tasks

  Scenario: Log in as an admin and do admin-y things
    Given I have no users
      And the following admin exists
      | login       | password | 
      | Zooey       | secret   |
      And the following activated user exists
      | login       | password      | 
      | dizmo       | wrangulator   |
   When I go to the home page
      And I fill in "login" with "Zooey"
      And I fill in "password" with "secret"
      And I press "Log in"
    Then I should see "We couldn't find that name in our database."
    When I go to the archive_faqs page
    Then I should see "Some commonly asked questions about the Archive are answered here"
      And I should not see "Some text"
    When I go to the admin_login page
      And I fill in "admin_login" with "dizmo"
      And I fill in "admin_password" with "wrangulator"
      And I press "Log in as admin"
    Then I should see "Authentication failed"
    When I go to the admin_login page
      And I fill in "admin_login" with "Zooey"
      And I fill in "admin_password" with "secret"
      And I press "Log in as admin"
    Then I should see "Logged in successfully"
    When I fill in "query" with "dizmo"
      And I press "Find"
    Then I should see "dizmo" within "#admin_users_table"
    When I follow "admin posts"
      And I follow "Archive FAQ" within "#main"
      And I should not see "Some text"
    When I follow "Add a new section"
      And I fill in "content" with "Some text, that is sufficiently long to pass validation."
      And I fill in "archive_faq_title" with "New subsection"
    When I press "Post"
    Then I should see "ArchiveFaq was successfully created"
    When I go to the archive_faqs page
    And I follow "New subsection"
    Then I should see "Some text, that is sufficiently long to pass validation" within ".user-generated-view"
