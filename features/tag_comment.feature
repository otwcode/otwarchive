@tags
Feature: Comment on tag
As a tag wrangler
I'd like to comment on a tag

  Scenario: Comment on a tag
    Given I have no users
      And I have no tags
      And the following activated tag wrangler exists
        | login       | password      |
        | dizmo       | wrangulator   |
      And the following admin exists
        | login       | password      |
        | Amelia      | secret        |
      And a fandom exists with name: "Stargate Atlantis", canonical: true
    When I am logged in as "dizmo" with password "wrangulator"
    Then I should see "Hi, dizmo!"
    When I follow "Tag Wrangling"
    Then I should see "Wrangling Home"
    When I view the tag "Stargate Atlantis"
    Then I should see "0 comments"
    When I follow "0 comments"
      And I fill in "Comment" with "Shouldn't this be a metatag with Stargate?"
      And I press "Add Comment"
    Then I should see "Comment created!"
      And I should see "Shouldn't this be a metatag with Stargate?"
      And I should see Posted nowish
    When I follow "Edit"
    Then the "Comment" field should contain "Shouldn't this be a metatag with Stargate?"
    When I fill in "Comment" with "Yep, we should have a Stargate franchise metatag."
      And I press "Update"
    Then I should see "Comment was successfully updated."
      And I should see "Yep, we should have a Stargate franchise metatag."
      And I should not see "Shouldn't this be a metatag with Stargate?"
      And I should see Last Edited nowish
    When I view the tag "Stargate Atlantis"
    Then I should see "1 comment"
    
    # admin can also comment on tags, issue 1428
    When I follow "Log out"
      And I go to the admin_login page
      And I fill in "admin_session_login" with "Amelia"
      And I fill in "admin_session_password" with "secret"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"
    When I view the tag "Stargate Atlantis"
    Then I should see "1 comment"
    When I follow "1 comment"
      And I fill in "Comment" with "Important policy decision"
      And I press "Add Comment"
    Then I should see "Comment created!"
    When I view the tag "Stargate Atlantis"
    Then I should see "2 comments"
    
    When I follow "Log out"
      And I am logged in as "dizmo" with password "wrangulator"
    When I follow "Tag Wrangling"
    Then I should see "Wrangling Home"
    When I follow "Discussion"
    Then I should see "Tag Wrangling Discussion"
      And I should see "Yep, we should have a Stargate franchise metatag."
      And I should see "Important policy decision"
 