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
    And I view the work "The One Where Neal is Awesome"
    And I follow "Add Chapter"
    And I fill in "content" with "A second chapter to test multi-chapter comments"
    And I press "Post Without Preview"
    And I follow "Entire Work"
    And I follow "Comments (1)"
  Then I should see "commenter on Chapter 1" within "h4.heading.byline"
    
Scenario: Comment threading, comment editing
  When I am logged in as "author"
    And I post the work "The One Where Neal is Awesome"
  When I am logged in as "commenter"
    And I post the comment "I loved this!" on the work "The One Where Neal is Awesome"
  When I follow "Reply"
    And I fill in "Comment" with "I wanted to say more." within ".odd"
    And I press "Comment" within ".odd"
  Then I should see "Comment created!"
    And I should see "I wanted to say more." within ".even"
  When I am logged in as "commenter2"
    And I view the work "The One Where Neal is Awesome"
    And I fill in "Comment" with "I loved it, too."
    And I press "Comment"
  Then I should see "Comment created!"
    And I should see "I loved it, too."
  When I am logged in as "author"
    And I view the work "The One Where Neal is Awesome"
    And I follow "Comments (3)"
    And I follow "Reply" within ".even"
    And I fill in "Comment" with "Thank you." within ".even"
    And I press "Comment" within ".even"
  Then I should see "Comment created!"
    And I should see "Thank you." within "ol.thread li ol.thread li ol.thread li"
  When I am logged in as "commenter"
    And I view the work "The One Where Neal is Awesome"
    And I follow "Comments (4)"
    And I follow "Reply" within ".thread .thread .odd"
    And I fill in "Comment" with "Mistaken comment" within ".thread .thread .odd"
    And I press "Comment" within ".thread .thread .odd"
    And I follow "Edit" within "ol.thread li ol.thread li ol.thread li ol.thread ul.navigation"
    And I fill in "Comment" with "Actually, I meant something different"
    And I press "Update"
  Then I should see "Actually, I meant something different"
    And I should see "Comment was successfully updated"
    And I should not see "Mistaken comment"
    And I should see "Posted"
    And I should see "Last Edited"
  When I am logged in as "commenter3"
    And I view the work "The One Where Neal is Awesome"
    And I follow "Comments (5)"
    And I follow "Reply" within ".thread .even"
    And I fill in "Comment" with "This should be nested" within ".thread .even"
    And I press "Comment" within ".thread .even"
  Then I should see "Comment created!"
    And I should not see "Mistaken comment"
    And I should see "Actually, I meant something different" within "ol.thread li ol.thread li ol.thread li ol.thread"
    And I should see "I loved it, too." within "ol.thread"
    And I should see "Thank you." within "ol.thread li ol.thread li ol.thread"
    And I should see "This should be nested" within "ol.thread li ol.thread li ol.thread"
    And I should not see "This should be nested" within ".thread .thread .thread .thread"
    And I should see "I loved this" within "ol.thread"

  Scenario: Try to post an invalid comment '
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
    And I set my preferences to receive copies of my own comments
    And I post the comment "Something" on the work "Generic Work"
  Then "author" should be emailed
    And "commenter" should be emailed
    And 1 email should be delivered to "commenter"
