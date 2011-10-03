@admin
Feature: Admin posts

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
    When I follow "admin posts"
      And I follow "Post AO3 News"
      Then I should see "New AO3 News Post"
    When I fill in "admin_post_title" with "Good news, everyone!"
      And I fill in "content" with "I've taught the toaster to feel love."
      And I fill in "admin_post_tag_list" with "quotes, futurama"
      And I press "Post"
    Then I should see "AdminPost was successfully created."
      And I should see "toaster" within ".admin-content"
      And I should see "futurama" within ".tags"