@admin
Feature: Admin Actions for Works and Bookmarks
  As an admin
  I should be able to perform special actions on works

  Scenario: Can hide works
    Given I am logged in as "regular_user"
      And I post the work "ToS Violation"
    When I am logged in as an admin
      And I view the work "ToS Violation"
      And I follow "Hide"
    Then I should see "Item has been hidden."
      And logged out users should not see the hidden work "ToS Violation" by "regular_user"
      And logged in users should not see the hidden work "ToS Violation" by "regular_user"
      And "regular_user" should see their work "ToS Violation" is hidden      

  Scenario: Can unhide works
    Given I am logged in as "regular_user"
      And I post the work "ToS Violation"
    When I am logged in as an admin
      And I view the work "ToS Violation"
      And I follow "Hide"
    Then I should see "Item has been hidden."
    When I follow "Make Visible"
    Then I should see "Item is no longer hidden."      
      And logged out users should see the unhidden work "ToS Violation" by "regular_user"
      And logged in users should see the unhidden work "ToS Violation" by "regular_user"

  Scenario: Can delete works
    Given I am logged in as "regular_user"
      And I post the work "ToS Violation"
    When I am logged in as an admin
      And I view the work "ToS Violation"
      And I follow "Delete"
    Then I should see "Item was successfully deleted."
      And 1 email should be delivered
      And the email should contain "deleted from the Archive by a site admin"
    When I am logged out
      And I am on regular_users's works page
    Then I should not see "ToS Violation"
    When I am logged in
      And I am on regular_users's works page
    Then I should not see "ToS Violation"  
      
  Scenario: Can hide bookmarks
    pending

  Scenario: Can edit tags on works
    Given basic tags
      And I am logged in as "regular_user"
      And I post the work "Changes" with fandom "User-Added Fandom" with freeform "User-Added Freeform" with category "M/M"
    When I am logged in as an admin
      And I view the work "Changes"
      And I follow "Edit Tags"
    When I select "Mature" from "Rating"
      And I uncheck "No Archive Warnings Apply"
      And I check "Choose Not To Use Archive Warnings"
      And I fill in "Fandoms" with "Admin-Added Fandom"
      And I fill in "Relationships" with "Admin-Added Relationship"
      And I fill in "Characters" with "Admin-Added Character"
      And I fill in "Additional Tags" with "Admin-Added Freeform"
      And I uncheck "M/M"
      And I check "Other"
    When I press "Post Without Preview"
    Then I should not see "User-Added Fandom"
      And I should see "Admin-Added Fandom"
      And I should not see "User-Added Freeform"
      And I should see "Admin-Added Freeform"
      And I should not see "M/M"
      And I should see "Other"
      And I should not see "No Archive Warnings Apply"
      And I should see "Creator Chose Not To Use Archive Warnings"
      And I should not see "Not Rated"
      And I should see "Mature"
      And I should see "Admin-Added Relationship"
      And I should see "Admin-Added Character"
  
  Scenario: Can edit external works
    Given basic tags
      And I am logged in as "regular_user"
      And I bookmark the external work "External Changes"
    When I am logged in as an admin
      And I view the external work "External Changes"
      And I follow "Edit"
    When I fill in "Author" with "Admin-Added Creator"
      And I fill in "Title" with "Admin-Added Title"
      And I fill in "Author's Summary" with "Admin-added summary"
      And I select "Mature" from "Rating"
      And I fill in "Fandoms" with "Admin-Added Fandom"
      And I fill in "Relationships" with "Admin-Added Relationship"
      And I fill in "Characters" with "Admin-Added Character"
      And I fill in "Additional Tags" with "Admin-Added Freeform"
      And I check "M/M"
    When I press "Update External work"
    Then I should see "Admin-Added Creator"
      And I should see "Admin-Added Title"
      And I should see "Admin-added summary"
      And I should see "Mature"
      And I should see "Admin-Added Fandom"
      And I should see "Admin-Added Character"
      And I should see "Admin-Added Freeform"
      And I should see "M/M"      
  
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