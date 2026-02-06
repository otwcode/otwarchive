@comments
Feature: Comment hiding

  Scenario: Hiding a comment replaces it with a placeholder message.
    Given I am logged in as "author"
      And I post the work "Popular Fic"
      And I am logged out
      And I am logged in as "commenter"
      And I post the comment "A suspicious comment" on the work "Popular Fic"
      And I am logged out

    # Delay to make sure the cache is expired when the comment is hidden:
    When it is currently 1 second from now
      And I am logged in as a super admin
      And I view the work "Popular Fic" with comments
      And I press "Hide Comment"
    Then I should see "Comment successfully hidden!"
      And I should see "This comment has been hidden by an admin."
      And I should see "A suspicious comment"
      And I should not see "This comment is under review by an admin and is currently unavailable."
    When I go to the admin-activities page
    Then I should see 1 admin activity log entry
      And I should see "hide comment"

    When I am logged in as "author"
      And I go to the home page
    Then I should see "Find your favorites"
      And I should not see "Unread messages"
      And I should not see "This comment is under review by an admin and is currently unavailable."
      And I should not see "A suspicious comment"
      And I should not see "This comment has been hidden by an admin."
    When I go to author's inbox page
    Then I should not see "This comment is under review by an admin and is currently unavailable."
      And I should not see "A suspicious comment"
      And I should not see "This comment has been hidden by an admin."
    When I view the work "Popular Fic" with comments
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
    When I go to the admin-activities page
    Then I should see 2 admin activity log entry
      And I should see "unhide comment"

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

  Scenario: Embedded images in hidden comments are replaced with their URLs.
    Given the work "Popular Fic"
      And I am logged in as "commenter"
      And I post the comment "OMG! <img src= 'https://example.com/image.jpg'>" on the work "Popular Fic"

    # Delay to make sure the cache is expired when the comment is hidden:
    When it is currently 1 second from now
      And I am logged in as a super admin
      And I view the work "Popular Fic" with comments
    Then I should see the image "src" text "https://example.com/image.jpg"
      And I should not see "OMG! img src="
      And I press "Hide Comment"
    Then I should see "Comment successfully hidden!"
    Then I should not see the image "src" text "https://example.com/image.jpg"
      And I should see "OMG! img src="
      And I should see "https://example.com/image.jpg"
    
    When I am logged in as "commenter"
      And I view the work "Popular Fic" with comments
      And I follow "Edit"
    Then I should see "Embedded images (<img> tags) will be displayed as HTML"

    When I am logged in as a super admin
      And I view the work "Popular Fic" with comments
      And I press "Make Comment Visible"
    Then I should see "Comment successfully unhidden!"
      And I should see the image "src" text "https://example.com/image.jpg"
      And I should not see "OMG! img src="
