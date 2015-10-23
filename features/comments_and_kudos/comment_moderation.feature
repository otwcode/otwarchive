@comments
Feature: Comment Moderation
  In order to avoid spam and troll comments
  As an author
  I'd like to be able to moderate comments
  
  
  Scenario: Turn off comments from anonymous users who can still leave kudos
    Given I am logged in as "author"
      And I set up the draft "No Anons"
      And I check "Anonymous commenting disabled"
      And I post the work without preview
      And I am logged out
    When I view the work "No Anons"
    Then I should see "Sorry, this work doesn't allow non-Archive users to comment."
    When I press "Kudos ♥"
    Then I should see "Thank you for leaving kudos"    
    
  Scenario: Turn on moderation
    Given I am logged in as "author"
      And I set up the draft "Moderation"
      And I check "Comments moderated"
      And I post the work without preview
    Then comment moderation should be enabled on "Moderation"
    
  Scenario: Post a moderated comment
    Given the moderated work "Moderation" by "author"
    When I am logged in as "commenter"
      And I post the comment "Fail comment" on the work "Moderation"
    Then I should see "Your comment was received! It will appear publicly after the author has approved it."
      And the comment on "Moderation" should be marked as unreviewed
      And I should not see "Comments (1)"
      And I should not see "Unreviewed Comments (1)"
      And I should not see "Approve"
      And 1 emails should be delivered
    When I am logged out
      And I view the work "Moderation"
    Then I should not see "Fail comment"
      And I should not see "Comments (1)"
      And I should not see "Unreviewed Comments"
      
  Scenario: Author comments do not need to be approved
    Given the moderated work "Moderation" by "author"
    When I am logged in as "author"
      And I post the comment "Fail comment" on the work "Moderation"
    Then I should not see "It will appear publicly after the author has approved it"
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
    