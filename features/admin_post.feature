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
  Then 1 email should be delivered to "testadmin@example.org"
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
  # admin gets notified of their own comment, this is not a bug unless:
  # TODO: comments should be able to belong to an admin officially, otherwise someone can spoof being an admin by using the admin name and email
    And 1 email should be delivered to "testadmin@example.org"
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
  # admin gets the user's reply twice, this is not a bug unless TODO above is fixed
  Then 2 emails should be delivered to "testadmin@example.org"
  
  # regular user edits their comment
  Given all emails have been delivered    
  When I follow "Edit"
    And I press "Update"
  Then 2 emails should be delivered to "testadmin@example.org"
  
  Scenario: User views RSS of admin posts
  
  Given I have posted an admin post
  When I am logged in
    And I go to the admin-posts page
  Then I should see "Subscribe with RSS"
  When I follow "Subscribe with RSS"
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
      And I should see "toaster" within ".admin"
      And I should see "futurama" within ".tags"
