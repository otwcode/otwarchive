@tag
Feature: Comment on tag
As a tag wrangler
I'd like to comment on a tag

Scenario: Log in as a tag wrangler and see wrangler pages.
        Comment on a tag
    Given I have no users
      And I have no tags
      And the following admin exists
      | login       | password | 
      | Zooey       | secret   |
      And the following activated user exists
      | login       | password      | 
      | dizmo       | wrangulator   |
      And I create the tag "TV Shows" with type "Media"
      And I create the tag "Stargate Atlantis" with type "Fandom"
    When I go to the admin_login page
      And I fill in "admin_login" with "Zooey"
      And I fill in "admin_password" with "secret"
      And I press "Log in as admin"
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
    When I view the tag "Stargate Atlantis"
    Then I should see "0 comments"
    When I follow "0 comments"
      And I follow "Add Comment"
      And I fill in "Comment" with "Shouldn't this be a metatag with Stargate?"
      And I press "Add Comment"
    Then I should see "Comment created!"
      And I should see "Shouldn't this be a metatag with Stargate?"
      And I should see Posted today
    When I view the tag "Stargate Atlantis"
    Then I should see "1 comment"
