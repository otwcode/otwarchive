@comments
Feature: Comment on work
  In order to give feedback
  As a reader
  I'd like to comment on a work

 Scenario: I cannot edit in a pseud that I don't own
 
   Given the work "Random Work"
   When I attempt to update a comment on "Random Work" with a pseud that is not mine
   Then I should not see "Comment was successfully updated"
     And I should see "You can't comment with that pseud"
 
 Scenario: Comment editing
 
   When I am logged in as "author"
     And I post the work "The One Where Neal is Awesome"
   When I am logged in as "commenter"
     And I post the comment "Mistaken comment" on the work "The One Where Neal is Awesome"
     And I wait 2 seconds
     And I debug comments
     And I follow "Edit"
   And I fill in "Comment" with "Actually, I meant something different"
     And I press "Update"
   Then I should see "Comment was successfully updated"
     And I debug comments
     And I should see "Actually, I meant something different"
     And I should not see "Mistaken comment"
     And I should see Last Edited in the right timezone
 
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
     And I follow "Edit" within "ol.thread li ol.thread li ol.thread li ol.thread ul.actions"
     And I fill in "Comment" with "Actually, I meant something different"
     And I press "Update"
   Then I should see "Comment was successfully updated"
     #TODO Someone should figure out why this fails intermittently on Travis. Caching? The success message is there but the old comment text lingers.
     And I should see "Actually, I meant something different"
     And I should not see "Mistaken comment"
     And I should see Last Edited in the right timezone
   When I am logged in as "commenter3"
     And I view the work "The One Where Neal is Awesome"
     And I follow "Comments (5)"
     And I follow "Reply" within ".thread .even"
     And I fill in "Comment" with "This should be nested" within ".thread .even"
     And I press "Comment" within ".thread .even"
   Then I should see "Comment created!"
     # TODO Someone should figure out why this fails intermittently on Travis. Caching? The success message is there but the old comment text lingers.
     And I should not see "Mistaken comment"
     And I should see "Actually, I meant something different" within "ol.thread li ol.thread li ol.thread li ol.thread"
     And I should see "I loved it, too." within "ol.thread"
     And I should see "Thank you." within "ol.thread li ol.thread li ol.thread"
     And I should see "This should be nested" within "ol.thread li ol.thread li ol.thread"
     And I should not see "This should be nested" within ".thread .thread .thread .thread"
     And I should see "I loved this" within "ol.thread"
 
