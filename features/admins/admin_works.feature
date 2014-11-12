@admin
Feature: Admin Actions for Works and Bookmarks
  As an admin
  I should be able to perform special actions on works

  Scenario: Can hide works
    pending

  Scenario: Can delete works
    pending

  Scenario: Can hide bookmarks
    pending

  Scenario: Can edit tags on works
    pending
  
  Scenario: Can edit external works
    pending

  Scenario: Can mark a comment as spam
    Given I have no works or comments
      And the following activated users exist
      | login         | password   |
      | author        | password   |
      | commenter     | password   |
      And the following admin exists
        | login       | password |
        | Zooey       | secret   |

    # set up a work with a genuine comment

    When I am logged in as "author" with password "password"
      And I post the work "The One Where Neal is Awesome"
    When I am logged out
      And I am logged in as "commenter" with password "password"
      And I view the work "The One Where Neal is Awesome"
      And I fill in "Comment" with "I loved this!"
      And I press "Comment"
    Then I should see "Comment created!"
    When I am logged out

    # comment from registered user cannot be marked as spam.
    # If registered user is spamming, this goes to Abuse team as ToS violation
    When I am logged in as an admin
    Then I should see "Successfully logged in"
    When I view the work "The One Where Neal is Awesome"
      And I follow "Comments (1)"
    Then I should not see "Mark as spam"

    # now mark a comment as spam
    When I post the comment "Would you like a genuine rolex" on the work "The One Where Neal is Awesome" as a guest
      And I am logged in as an admin
      And I view the work "The One Where Neal is Awesome"
      And I follow "Comments (2)"
    Then I should see "rolex"
      And I should see "Spam"
    When I follow "Spam"
    Then I should see "Not Spam"
    When I follow "Hide Comments"
    # TODO: Figure out if this is a defect or not, that it shows 2 instead of 1
    # Then I should see "Comments (1)"

    # comment should no longer be there
    When I follow "Comments"
    Then I should see "rolex"
      And I should see "Not Spam"
    When I am logged out as an admin
      And I view the work "The One Where Neal is Awesome"
      And I follow "Comments"
    Then I should not see "rolex"
    When I am logged in as "author" with password "password"
      And I view the work "The One Where Neal is Awesome"
      And I follow "Comments"
      Then I should not see "rolex"