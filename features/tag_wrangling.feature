@users
Feature: Tag wrangling

  Scenario: Log in as a tag wrangler and see wrangler pages
    Given I have no users
      And the following admin exists
      | login       | password | 
      | Zooey       | secret   |
      And the following activated user exists
      | login       | password      | 
      | dizmo       | wrangulator   |
    When I am logged in as "dizmo" with password "wrangulator"
    Then I should not see "Tag Wrangling"
    When I follow "Log out"
      And I go to the admin_login page
      And I fill in "admin_login" with "Zooey"
      And I fill in "admin_password" with "secret"
      And I press "Log in"
    Then I should see "Logged in successfully"
    When I fill in "query" with "dizmo"
      And I press "Find"
    Then I should see "dizmo" within "#admin_users_table"
    When I check "user_tag_wrangler"
      And I press "Update"
    Then I should see "User was successfully updated"
    When I follow "Log out"
      And I am logged in as "dizmo" with password "wrangulator"
    Then I should see "Hi, dizmo!"
    When I follow "Tag Wrangling"
    Then I should see "Wrangling Home"
    
