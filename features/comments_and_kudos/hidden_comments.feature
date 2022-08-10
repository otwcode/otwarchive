@comments
Feature: Comment hiding

  Scenario: Hiding a comment replaces it with a placeholder message.

    Given I am logged in as "author"
      And I post the work "Popular Fic"
      And I am logged out
      And I am logged in as "commenter"
      And I post the comment "A suspicious comment" on the work "Popular Fic"
      And I am logged out

    When I am logged in as a super admin
      And I view the work "Popular Fic" with comments
      And I press "Hide Comment"
    Then I should see "Comment successfully hidden!"
      And I should see "This comment has been hidden by an admin."
      And I should see "A suspicious comment"
      And I should not see "This comment is under review by an admin and is currently unavailable."

    When I am logged in as "author"
      And I go to the home page
    Then I should see "This comment is under review by an admin and is currently unavailable."
      And I should not see "A suspicious comment"
      And I should not see "This comment has been hidden by an admin."
      And I follow "My Inbox"
    Then I should see "This comment is under review by an admin and is currently unavailable."
      And I should not see "A suspicious comment"
      And I should not see "This comment has been hidden by an admin."
      And I view the work "Popular Fic" with comments
    Then I should see "This comment is under review by an admin and is currently unavailable."
      And I should not see "A suspicious comment"
      And I should not see "This comment has been hidden by an admin."
      And I should not see a "Make Comment Visible" button

    When I am logged in as "commenter"
      And I view the work "Popular Fic" with comments
    Then I should see "A suspicious comment"
      And I should see "This comment has been hidden by an admin."

    When I am logged in as a super admin
      And I view the work "Popular Fic" with comments
      And I press "Make Comment Visible"
    Then I should see "Comment successfully unhidden!"

    When I am logged in as "author"
      And I go to the home page
    Then I should see "A suspicious comment"
      And I follow "My Inbox"
    Then I should see "A suspicious comment"
      And I view the work "Popular Fic" with comments
    Then I should see "A suspicious comment"
      And I should not see a "Hide Comment" button

    When I am logged in as "commenter"
      And I view the work "Popular Fic" with comments
    Then I should see "A suspicious comment"
      And I should not see "This comment has been hidden by an admin."
