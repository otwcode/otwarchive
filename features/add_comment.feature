Feature: Comment on work 
In order to give feedback
As a redaer
I'd like to comment on a work

Scenario: When logged in I can comment on a work 
Given the following activated user exists
| login         | password   |
| author        | password   |
And given the following activated user exists
| login         | password   |
| commenter     | password   | 
When I am logged in as "author" with password "password"
And I post the work "The One Where Neal is Awesome"
When I am logged out
And I am logged in as "commenter" with password "password" 
Then I view the work "The One Where Neal is Awesome" 
Then I should see "Add Comment" 
When I follow "Add Comment" 
Then I fill in "comment" with "I loved this!"
And I press "Add comment" 
Then I should see "Comment created!" 
And I should see "I loved this!"
