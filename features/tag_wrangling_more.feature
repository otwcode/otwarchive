@tags @tag_wrangling
Feature: Tag wrangling: assigning wranglers, using the filters on the Wranglers page

  Scenario: Log in as a tag wrangler and see wrangler pages.
        View new tags in your fandoms
    Given I have loaded the fixtures
      And the following admin exists
      | login       | password |
      | Zooey       | secret   |
      And the following activated user exists
      | login       | password      |
      | dizmo       | wrangulator   |
      And the following activated tag wrangler exists
      | login       | password      |
      | Enigel      | wrangulator   |
      And I have loaded the "roles" fixture
      
    # admin making a user into a tag wrangler
    When I go to the admin_login page
      And I fill in "admin_session_login" with "Zooey"
      And I fill in "admin_session_password" with "secret"
      And I press "Log in as admin"
      And I fill in "query" with "dizmo"
      And I press "Find"
    Then I should see "dizmo" within "#admin_users_table"
    When I check "user_roles_1"
      And I press "Update"
    Then I should see "User was successfully updated"
    When I follow "Log out"
    
    # accessing tag wrangling pages
      And I am logged in as "dizmo" with password "wrangulator"
      And I follow "Tag Wrangling"
    Then I should see "Wrangling Home"
      And I should not see "first fandom"
    When I follow "Wranglers"
    Then I should see "Tag Wrangling Assignments"
      And I should see "first fandom"
    When I view the tag "first fandom"
    Then I should see "Edit"
    When I follow "Edit" within ".header"
    Then I should see "Edit first fandom Tag"
    
    # assigning media to a fandom
    When I fill in "Medias" with "TV Shows"
      And I press "Save changes"
    Then I should see "Tag was updated"
    When I follow "Tag Wrangling"
    Then I should see "Wrangling Home"
      And I should not see "first fandom"
    When I follow "Wranglers"
    Then I should see "Tag Wrangling Assignments"
      And I should see "first fandom"
      And I should not see "dizmo" within ".wranglers"
    
    # assigning a fandom to oneself
    When I fill in "tag_fandom_string" with "first fandom"
      And I press "Assign"
      And I follow "Wrangling Home"
      And I follow "Wranglers"
    Then I should see "first fandom"
      And I should see "dizmo" within ".wranglers"
    Given I add the fandom "first fandom" to the character "Person A"
    
    # checking that wrangling home shows unfilterables
    When I follow "Wrangling Home"
    Then I should see "first fandom"
      And I should see "Unfilterable"
    When I follow "first fandom"
    Then I should see "Wrangle Tags for first fandom"
      And I should see "Characters (1)"
    
    When I follow "Log out"
      And I am logged in as "Enigel" with password "wrangulator"
      And I follow "Tag Wrangling"
    
    # assigning another wrangler to a fandom
    When I follow "Wranglers"
      And I fill in "fandom_string" with "Ghost"
      And I press "Go"
    Then I should see "Ghost Soup"
      And I should not see "first fandom"
    When I select "dizmo" from "assignments_1234_"
      And I press "Assign"
    Then I should see "Wranglers were successfully assigned"

    # the filters on the Wranglers page
    When I select "TV Shows" from "media_id"
      And I fill in "fandom_string" with ""
      And I press "Go"
    Then "TV Shows" should be selected within "media_id"
      And I should see "first fandom"
      And I should not see "second fandom"
    When I select "dizmo" from "wrangler_id"
      And I press "Go"
    Then I should see "first fandom"
      And I should not see "Ghost Soup"
    When I select "" from "media_id"
      And I press "Go"
    Then "dizmo" should be selected within "wrangler_id"
      And I should see "Ghost Soup"
      And I should see "first fandom"
