@admin @comments
Feature: Admin Actions to Post News
  In order to post news items
  As an an admin
  I want to be able to use the Admin Posts screen

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
    # Someone can spoof being an admin by using the admin name and a different email, but their icon will not match
    # We want to improve this so that the name is linked and the spoof is more obvious
    When "Issue AO3-3685" is fixed
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

  Scenario: Evil user can impersonate admin in comments
  # However, they can't use an icon, so the admin's icon is the guarantee that they're real
  # also their username will be plain text and not a link

    Given I have posted an admin post
    When I am logged out as an admin
      And I am logged in as "happyuser"
      And I go to the admin-posts page
    When I follow "Comment"
      And I fill in "Comment" with "Excellent, my dear!"
      And I press "Comment"
    When I am logged out
      And I go to the admin-posts page
      And I follow "Default Admin Post"
      And I fill in "Comment" with "Behold, ye mighty, and despair!"
      And I fill in "Name" with "admin"
      And I fill in "Email" with "admin@example.com"
      And I press "Comment"
    Then I should see "Comment created!"
      And I should see "admin"
      And I should see "Behold, ye mighty, and despair!"

  Scenario: User views RSS of admin posts

    Given I have posted an admin post
    When I am logged in
      And I go to the admin-posts page
    Then I should see "RSS Feed"
    When I follow "RSS Feed"
    Then I should see "Default Admin Post"

  Scenario: Make a translation of an admin post
    Given I have posted an admin post
      And basic languages
      And I am logged in as an admin
    When I make a translation of an admin post
      And I am logged in as "ordinaryuser"
    Then I should see a translated admin post

  Scenario: Make a translation of an admin post stop being a translation
    Given I have posted an admin post
      And basic languages
      And I am logged in as an admin
      And I make a translation of an admin post
    When I follow "Edit Post"
      And I fill in "Translation of" with ""
      And I press "Post"
    When I am logged in as "ordinaryuser"
    Then I should not see a translated admin post

  Scenario: Log in as an admin and create an admin post with tags
    Given I have no users
      And the following admin exists
      | login      | password |
      | Elz        | secret   |
    When I go to the admin login page
      And I fill in "admin_login" with "Elz"
      And I fill in "admin_password" with "secret"
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
      And I should see "futurama" within "dd.tags"

  Scenario: Admin posts should show both translations and tags
    Given I have posted an admin post with tags
      And basic languages
      And I am logged in as an admin
    When I make a translation of an admin post
      And I am logged in as "ordinaryuser"
    Then I should see a translated admin post with tags

  Scenario: If an admin post has characters like & and < and > in the title, the escaped version will not show on the various admin post pages
    Given I am logged in as an admin
    When I follow "Admin Posts"
      And I follow "Post AO3 News"
      And I fill in "admin_post_title" with "App News & a <strong> Warning"
      And I fill in "content" with "We're delaying it a week for every question we get."
    When I press "Post"
    Then I should see the page title "App News & a <strong> Warning"
      And I should not see "App News &amp; a &lt;strong&gt; Warning"
    When I go to the admin-posts page
    Then I should see "App News & a <strong> Warning"
      And I should not see "App News &amp; a &lt;strong&gt; Warning"
    When I go to the home page
    Then I should see "App News & a <strong> Warning"
      And I should not see "App News &amp; a &lt;strong&gt; Warning"
    When I am logged out as an admin
      And I go to the admin-posts page
    Then I should see "App News & a <strong> Warning"
      And I should not see "App News &amp; a &lt;strong&gt; Warning"
      
  Scenario: Admin post should be shown on the homepage
    Given I have posted an admin post
    When I am on the homepage
    Then I should see "News"
      And I should see "All News"
      And I should see "Default Admin Post"
      And I should see "Published:"
      And I should see "Comments:"
      And I should see "Content of the admin post."
      And I should see "Read more..."
    When I follow "Read more..."
    Then I should see "Default Admin Post"
      And I should see "Content of the admin post."

  Scenario: Admin posts without paragraphs should have placeholder preview text on the homepage
    Given I have posted an admin post without paragraphs
    When I am on the homepage
    Then I should see "Admin Post Without Paragraphs"
      And I should see "No preview is available for this news post."

  Scenario: Edits to an admin post should appear on the homepage
    Given I have posted an admin post without paragraphs
      And I am logged in as an admin
    When I go to the admin-posts page
      And I follow "Edit"
      And I fill in "admin_post_title" with "Edited Post"
      And I fill in "content" with "<p>Look! A preview!</p>"
      And I press "Post"
    When I am on the homepage
    Then I should see "Edited Post"
      And I should see "Look! A preview!"
      And I should not see "Admin Post Without Paragraphs"
      And I should not see "No preview is available for this news post."

  Scenario: A deleted admin post should be removed from the homepage
    Given I have posted an admin post
      And I am logged in as an admin
    When I go to the admin-posts page
      And I follow "Delete"
    When I go to the homepage
    Then I should not see "Default Admin Post"
