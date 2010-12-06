Feature: Comment on work 
  In order to give feedback
  As a reader
  I'd like to comment on a work

Scenario: When logged in I can comment on a work, comment threading, comment editing
  Given I have no works or comments
    And the following activated user exists
    | login         | password   |
    | author        | password   |
    And given the following activated users exist
    | login         | password   |
    | commenter     | password   |
    | commenter2    | password   |
    | commenter3    | password   |
  When I am logged in as "author" with password "password"
    And I post the work "The One Where Neal is Awesome"
  When I am logged out
    And I am logged in as "commenter" with password "password" 
    And I view the work "The One Where Neal is Awesome"
    And I fill in "Comment" with "I loved this!"
    And I press "Add Comment" 
  Then I should see "Comment created!" 
    And I should see "I loved this!" within ".odd"
  When I follow "Reply"
    And I fill in "Comment" with "I wanted to say more." within ".odd"
    And I press "Add Comment" within ".odd"
  Then I should see "Comment created!"
    And I should see "I wanted to say more." within ".even"
  When I follow "Log out" 	
    And I am logged in as "commenter2" with password "password" 
    And I view the work "The One Where Neal is Awesome"
    And I fill in "Comment" with "I loved it, too."
    And I press "Add Comment"
  Then I should see "Comment created!"
    And I should see "I loved it, too."
  When I follow "Log out" 	
    And I am logged in as "author" with password "password" 
    And I view the work "The One Where Neal is Awesome"
    And I follow "Read Comments (3)"
    And I follow "Reply" within ".even"
    And I fill in "Comment" with "Thank you." within ".even"
    And I press "Add Comment" within ".even"
  Then I should see "Comment created!"
    And I should see "Thank you." within ".odd"
  When I am logged out
    And I am logged in as "commenter" with password "password" 
    And I view the work "The One Where Neal is Awesome"
    And I follow "Read Comments (4)"
    And I follow "Reply" within ".thread .thread .odd"
    And I fill in "Comment" with "Mistaken comment" within ".thread .thread .odd"
    And I press "Add Comment" within ".thread .thread .odd"
    And I follow "Edit" within ".even"
    And I fill in "Comment" with "Actually, I meant something different"
    And I press "Update"
  Then I should see "Actually, I meant something different"
    And I should see "Comment was successfully updated"
    And I should not see "Mistaken comment"
    And I should see "Posted"
    And I should see "Last Edited"
  When I am logged out
    And I am logged in as "commenter3" with password "password" 
    And I view the work "The One Where Neal is Awesome"
    And I follow "Read Comments (5)"
    And I follow "Reply" within ".thread .even"
    And I fill in "Comment" with "This should be nested" within ".thread .even"
    And I press "Add Comment" within ".thread .even"
  Then I should see "Comment created!"
    And I should not see "Mistaken comment"
    And I should see "Actually, I meant something different" within ".even"
    And I should see "I loved it, too." within ".even"
    And I should see "Thank you." within ".thread .thread .odd"
    And I should see "This should be nested" within ".thread .thread .thread .odd"
    And I should not see "This should be nested" within ".thread .thread .thread .thread"
    And I should see "I loved this" within ".odd"
