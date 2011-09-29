@admin
Feature: Admin posts

  Scenario: Make an admin post
  
  Given I am logged in as an admin
  When I make an admin post
  Then I should see "AdminPost was successfully created."
  
  Scenario: Receive comment notifications for comments posted to an admin post
  
  Given I have posted an admin post
  
  # regular user replies to admin post
  When I am logged out as an admin
    And I am logged in as "happyuser"
    And I go to the admin-posts page
  Given all emails have been delivered    
  When I follow "Add Comment"
    And I fill in "Comment" with "Excellent, my dear!"
    And I press "Add Comment"
  Then 1 email should be delivered to "testadmin@example.org"
    And the email should contain "Excellent"

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
    And 1 email should be delivered to "happyuser"
  
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
