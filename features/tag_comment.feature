@tag
Feature: Comment on tag
As a tag wrangler
I'd like to comment on a tag

  Scenario: Comment on a tag
    Given I have no users
      And I have no tags
      And the following activated tag wrangler exists
        | login       | password      |
        | dizmo       | wrangulator   |
      And a fandom exists with name: "Stargate Atlantis", canonical: true
    When I am logged in as "dizmo" with password "wrangulator"
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
      And I should see Posted nowish
    When I follow "Edit"
    Then the "Comment" field should contain "Shouldn't this be a metatag with Stargate?"
    When I fill in "Comment" with "Yep, we should have a Stargate franchise metatag."
      And I press "Update"
    Then I should see "Comment was successfully updated."
      And I should see "Yep, we should have a Stargate franchise metatag."
      And I should see Last Edited nowish
    When I view the tag "Stargate Atlantis"
    Then I should see "1 comment"
 