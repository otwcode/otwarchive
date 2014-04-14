@admin @comments
Feature: Admin posts

  Scenario: Make an admin post
  
  Given I am logged in as an admin
  When I make an admin post
  Then I should see "Admin Post was successfully created."
  
  Scenario: Receive comment notifications for comments posted to an admin post
  
  Given I have posted an admin post
  
  # regular user replies to admin post
  When I am logged out as an admin
    And I am logged in as "happyuser"
    And I go to the admin-posts page
  Given all emails have been delivered    
  When I follow "Comment"
    And I fill in "Comment" with "Excellent, my dear!"
    And I press "Comment"
  # notification to the admin list for admin post
  Then 1 email should be delivered to "admin@example.org"
    And the email should contain "Excellent"

  # admin replies to comment of regular user
  Given I am logged out
    And I am logged in as an admin
    And I go to the admin-posts page
    And I follow "Default Admin Post"
  Given all emails have been delivered    
  When I follow "Comments (1)"
    And I follow "Reply"
    And I fill in "Comment" with "Thank you very much!" within ".odd"
    And I press "Comment" within ".odd"
  Then I should see "Comment created"
  # TODO: comments should be able to belong to an admin officially, otherwise someone can spoof being an admin by using the admin name and email
  # notification to the admin list for admin post
    And 1 email should be delivered to "admin@example.org"
  # reply to the user
    And 1 email should be delivered to "happyuser"
  
  # regular user replies to comment of admin
  Given I am logged out as an admin
    And I am logged in as a random user
    And I go to the admin-posts page
  Given all emails have been delivered    
  When I follow "Read 2 Comments"
    And I follow "Reply" within ".even"
    And I fill in "Comment" with "Oh, don't grow too big a head, you." within ".even"
    And I press "Comment" within ".even"
  # reply to the admin as a regular user
  Then 1 email should be delivered to "testadmin@example.org"
  # notification to the admin list for admin post
    And 1 email should be delivered to "admin@example.org"
  
  # regular user edits their comment
  Given all emails have been delivered    
  When I follow "Edit"
    And I press "Update"
  # reply to the admin as a regular user
  Then 1 email should be delivered to "testadmin@example.org"
  # notification to the admin list for admin post
    And 1 email should be delivered to "admin@example.org"
  
  Scenario: User views RSS of admin posts
  
  Given I have posted an admin post
  When I am logged in
    And I go to the admin-posts page
  Then I should see "Subscribe to the feed"
  When I follow "Subscribe to the feed"
  Then I should see "Default Admin Post"
  
  Scenario: Make a translation of an admin post
  
  Given I have posted an admin post
    And basic languages
    And I am logged in as an admin
  When I make a translation of an admin post
    And I am logged in as "ordinaryuser"
  Then I should see a translated admin post

  Scenario: Log in as an admin and create an admin post with tags
  
    Given I have no users
      And the following admin exists
      | login      | password |
      | Elz        | secret   |
    When I go to the admin_login page
      And I fill in "admin_session_login" with "Elz"
      And I fill in "admin_session_password" with "secret"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"
    When I follow "Admin Posts"
      And I follow "Post AO3 News"
      Then I should see "New AO3 News Post"
    When I fill in "admin_post_title" with "Good news, everyone!"
      And I fill in "content" with "I've taught the toaster to feel love."
      And I fill in "admin_post_tag_list" with "quotes, futurama"
      And I press "Post"
    Then I should see "Admin Post was successfully created."
      And I should see "toaster" within "div.admin.home"
      And I should see "futurama" within ".tags"

  Scenario: Check AdminPost links on home page with only 3 total posts

    Given I have no users
      And the following admin exists
        | login      | password |
        | Scott      | secret   |

    When I go to the admin_login page
      And I fill in "admin_session_login" with "Scott"
      And I fill in "admin_session_password" with "secret"
      And I press "Log in as admin"
    When there are 3 Admin Posts
      And I go to the home page
    Then I should see "Amazing News"
      And I should not see "More news"

  Scenario: Check AdminPost links on home page with 4 total posts

    Given I have no users
    And the following admin exists
      | login      | password |
      | Scott      | secret   |

    When I go to the admin_login page
      And I fill in "admin_session_login" with "Scott"
      And I fill in "admin_session_password" with "secret"
      And I press "Log in as admin"
    When there are 4 Admin Posts
      And I go to the home page
    Then I should see "More news"
      And I should see "Amazing News"
