@comments
Feature: Comment on work 
  In order to give feedback
  As a reader
  I'd like to comment on a work

Scenario: Comment links from downloads and static pages

  When I am logged in as "author"
    And I post the work "Generic Work"
  When I am logged in as "commenter"
    And I visit the new comment page for the work "Generic Work"
  Then I should see the comment form

Scenario: When logged in I can comment on a work

  Given I have no works or comments
  When I am logged in as "author"
    And I post the work "The One Where Neal is Awesome"
  When I am logged in as "commenter"
    And I view the work "The One Where Neal is Awesome"
    And I fill in "Comment" with "I loved this!"
    And I press "Comment" 
  Then I should see "Comment created!" 
    And I should see "I loved this!" within ".odd"
    And I should not see "on Chapter 1" within ".odd"
  When I am logged in as "author"
    And a chapter is added to "The One Where Neal is Awesome"
    And I follow "Entire Work"
    And I follow "Comments (1)"
  Then I should see "commenter on Chapter 1" within "h4.heading.byline"
  
Scenario: I cannot comment with a pseud that I don't own

  Given the work "Random Work"
  When I attempt to comment on "Random Work" with a pseud that is not mine
  Then I should not see "Comment created!"
    And I should not see "on Chapter 1"
    And I should see "You can't comment with that pseud"

  Scenario: Try to post an invalid comment

    When I am logged in as "author"
      And I post the work "Generic Work"
    When I am logged in as "commenter"
      And I view the work "Generic Work"
      And I compose an invalid comment
      And I press "Comment"
    Then I should see "must be less than"
      And I should see "Sed mollis sapien ac massa pulvinar facilisis"
    When I fill in "Comment" with "This is a valid comment"
      And I press "Comment"
      And I follow "Reply" within ".thread .odd"
      And I compose an invalid comment within ".thread .odd"
      And I press "Comment" within ".thread .odd"
    Then I should see "must be less than"
      And I should see "Sed mollis sapien ac massa pulvinar facilisis"
    When I fill in "Comment" with "This is a valid reply comment"
      And I press "Comment"
      And I follow "Edit"
      And I compose an invalid comment
      And I press "Update"
    Then I should see "must be less than"
      And I should see "Sed mollis sapien ac massa pulvinar facilisis"
      
Scenario: Don't receive comment notifications of your own comments by default

  When I am logged in as "author"
    And I post the work "Generic Work"
  When I am logged in as "commenter"
    And I post the comment "Something" on the work "Generic Work"
  Then "author" should be emailed
    And "commenter" should not be emailed
    
Scenario: Set preference and receive comment notifications of your own comments

  When I am logged in as "author"
    And I post the work "Generic Work"
  When I am logged in as "commenter"
    And I set my preferences to turn on copies of my own comments
    And I post the comment "Something" on the work "Generic Work"
  Then "author" should be emailed
    And "commenter" should be emailed
    And 1 email should be delivered to "commenter"
