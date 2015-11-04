@comments
Feature: Comment Moderation
  In order to avoid spam and troll comments
  As an author
  I'd like to be able to moderate comments
  
  
  Scenario: Turn off comments from anonymous users who can still leave kudos
    Given I am logged in as "author"
      And I set up the draft "No Anons"
      And I check "Disable anonymous commenting"
      And I post the work without preview
      And I am logged out
    When I view the work "No Anons"
    Then I should see "Sorry, this work doesn't allow non-Archive users to comment."
    When I press "Kudos ♥"
    Then I should see "Thank you for leaving kudos"    
    
  Scenario: Turn on moderation
    Given I am logged in as "author"
      And I set up the draft "Moderation"
      And I check "Enable comment moderation"
      And I post the work without preview
    Then comment moderation should be enabled on "Moderation"
    When I am logged in as "commenter"
      And I view the work "Moderation"
    Then I should see "has chosen to moderate comments"
    
  Scenario: Post a moderated comment
    Given the moderated work "Moderation" by "author"
    When I am logged in as "commenter"
      And I set my preferences to turn on copies of my own comments
      And I post the comment "Fail comment" on the work "Moderation"
    Then I should see "Your comment was received! It will appear publicly after the work creator has approved it."
      And the comment on "Moderation" should be marked as unreviewed
      And I should not see "Unreviewed Comments (1)"
      And I should not see "Comments:1"
      And "author" should be emailed
      And the email to "author" should contain "will not appear until you approve"
      And the email to "author" should contain "Review comments on"
      And the email to "author" should not contain "Reply"
      And "commenter" should be emailed
      And the email to "commenter" should contain "will not appear until approved"
      And the email to "commenter" should not contain "Go to the thread starting from"
    When I am logged out
      And I view the work "Moderation"
    Then I should not see "Fail comment"
      And I should not see "Comments:1"
      And I should not see "Unreviewed Comments"
      
  Scenario: Author comments do not need to be approved
    Given the moderated work "Moderation" by "author"
    When I am logged in as "author"
      And I post the comment "Fail comment" on the work "Moderation"
    Then I should not see "It will appear publicly after the work creator has approved it."
      And the comment on "Moderation" should not be marked as unreviewed
      And I should see "Comment created"
      And I should not see "Unreviewed Comments (1)"
      
  Scenario: Moderated comments can be approved by the author
    Given the moderated work "Moderation" by "author"
      And I am logged in as "commenter"
      And I post the comment "Test comment" on the work "Moderation"
    When I am logged in as "author"
      And I view the work "Moderation"
    Then I should see "Unreviewed Comments (1)"
      And the comment on "Moderation" should be marked as unreviewed
    When I follow "Unreviewed Comments (1)"
    Then I should see "Test comment"
    When I follow "Approve"
    Then I should see "Comment approved"
    When I am logged out
      And I view the work "Moderation"
    Then I should see "Comments (1)"
    When I follow "Comments (1)"
    Then I should see "Test comment"
      And the comment on "Moderation" should not be marked as unreviewed
      
  Scenario: Moderated comments can be approved from the inbox
    Given the moderated work "Moderation" by "author"
      And I am logged in as "commenter"
      And I post the comment "Test comment" on the work "Moderation"
    When I am logged in as "author"
      And I go to my inbox page
    Then I should see "Test comment"
      And I should see "Approve"
      And I should not see "Reply"
    When I follow "Approve"
    Then I should see "Reply"
      And I should not see "Approve"
    When I view the work "Moderation"
    Then I should see "Comments (1)"
      And I should not see "Unreviewed Comments (1)"

  Scenario: Comments can be approved from the home page inbox
    Given the moderated work "Moderation" by "author"
      And I am logged in as "commenter"
      And I post the comment "Test comment" on the work "Moderation"
    When I am logged in as "author"
      And I go to the home page
    Then I should see "Test comment"
      And I should see "Unreviewed"
      And I should see "Approve"
    When I follow "Approve"
    Then I should see "Reply"
    When I view the work "Moderation"
    Then I should see "Comments (1)"
      And I should not see "Unreviewed Comments (1)"
    
  Scenario: Moderated comments can be deleted by the author
    Given the moderated work "Moderation" by "author"
      And I am logged in as "commenter"
      And I post the comment "Test comment" on the work "Moderation"
    When I am logged in as "author"
      And I view the unreviewed comments page for "Moderation"
    # The following won't work until deleting comments without javascript is fixed
    #   And I delete the comment
    # Then I should see "Comment deleted"
    #   And I should not see "Test comment"
    #   And I should see "No unreviewed comments"
      
  Scenario: Moderation should work on threaded comments
    Given the moderated work "Moderation" by "author"
      And I am logged in as "author"
      And I post the comment "Test comment" on the work "Moderation"
    When I am logged in as "commenter"
      And I view the work "Moderation"
      And I follow "Comments (1)"
      And I follow "Reply" within ".odd"
      And I fill in "Comment" with "A moderated reply" within ".odd"
      And I press "Comment" within ".odd"
    Then I should see "It will appear publicly"
      And I should not see "A moderated reply"
    When I am logged in as "author"
      And I view the unreviewed comments page for "Moderation"
    Then I should see "A moderated reply"
    When I follow "Approve"
    Then I should see "Comment approved"
    When I view the work "Moderation"
      And I follow "Comments (2)"
    Then I should see "A moderated reply" within ".even"

  Scenario: The author cannot reply to unapproved comments
    Given the moderated work "Moderation" by "author"
      And I am logged in as "commenter"
      And I post the comment "Test comment" on the work "Moderation"
    When I am logged in as "author"
      And I view the unreviewed comments page for "Moderation"
    Then I should not see "Reply"
    When I go to my inbox page
    Then I should see "Test comment"
      And I should not see "Reply"
      And I should see "Approve"
      
  Scenario: Users should not see unapproved replies to their own comments
    Given the moderated work "Moderation" by "author" with the approved comment "Test comment" by "commenter"
      And I am logged in as "new_commenter"
      And I set my preferences to turn on copies of my own comments
    When I view the work "Moderation"
      And I follow "Comments (1)"
      And I follow "Reply" within ".odd"
      And I fill in "Comment" with "A moderated reply" within ".odd"
      And I press "Comment" within ".odd"
    # emails should only be delivered to author and new_commenter
    Then "author" should be emailed
      And "new_commenter" should be emailed
      And "commenter" should not be emailed
    When all emails have been delivered
      And I am logged in as "commenter"
      And I set my preferences to turn on copies of my own comments
      And I go to my inbox page
    Then I should not see "A moderated reply"
    When I view the work "Moderation"
      And I follow "Comments (1)"
    Then I should see "Test comment"
      And I should not see "A moderated reply"
    When I am logged in as "author"
      And I view the unreviewed comments page for "Moderation"
      And I follow "Approve"
    Then "commenter" should be emailed
      And "author" should not be emailed
      And "new_commenter" should not be emailed
    When I am logged in as "commenter"
      And I go to my inbox page
    Then I should see "A moderated reply"
    
  Scenario: When I turn off moderation, comments stay unreviewed
    Given the moderated work "Moderation" by "author"
      And I am logged in as "commenter"
      And I post the comment "Interesting Comment" on the work "Moderation"      
    When I am logged in as "author"
      And I edit the work "Moderation"
      And I uncheck "Enable comment moderation"
      And I post the work without preview
    Then comment moderation should not be enabled on "Moderation"
    When I view the work "Moderation"
    Then I should see "Unreviewed Comments"
      And I should not see "Comments:1"
    When I go to my inbox page
    Then I should not see "Reply"
      And I should see "Approve"
    When I am logged in as "commenter"
      And I view the work "Moderation"
    Then I should not see "has chosen to moderate comments"
      And I should not see "Interesting Comment"
    When I post the comment "New Comment" on the work "Moderation"
      And I view the work "Moderation"
    Then I should see "Comments:1"
    When I follow "Comments (1)"
    Then I should see "New Comment"
      And I should not see "Interesting Comment"
    
  Scenario: When a comment is edited significantly it gets moderated again
    Given the moderated work "Moderation" by "author"
      And I am logged in as "commenter"
      And I post the comment "Interesting Comment" on the work "Moderation"      
      And I am logged in as "author"
      And I view the unreviewed comments page for "Moderation"
      And I follow "Approve"
    When I am logged in as "commenter"
      And I view the work "Moderation"
      And I follow "Comments (1)"
      And I follow "Edit"
      And I fill in "Comment" with "Interesting Commentary"
      And I press "Update"
    Then I should see "Comments (1)"
      And I should see "Interesting Commentary"
    When I follow "Edit"
      And I fill in "Comment" with "AHAHAHA LOOK I HAVE TOTALLY CHANGED IT"
      And I press "Update"
    Then I should not see "Comments (1)"
      And I should not see "Interesting Comment"
      And I should not see "AHAHAHA LOOK I HAVE TOTALLY CHANGED IT"
      And the comment on "Moderation" should be marked as unreviewed