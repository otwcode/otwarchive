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
And a warning exists with name: "Choose Not To Use Archive Warnings", canonical: true
When I am logged in as "author" with password "password"
Then I go to the new work page
And I select "Not Rated" from "Rating"
And I check "Choose Not To Use Archive Warnings"
And I fill in "Fandoms" with "White Collar"
And I fill in "Work Title" with "The One Where Neal is Awesome"
And I fill in "content" with "Neal was awesome. Peter was awesome. The end."
And I press "Preview"
And I press "Post"
		Then I should see "Work was successfully posted."
When I follow "Log out" 	
And I am logged in as "commenter" with password "password" 
Then I view the work "The One Where Neal is Awesome" 
Then I should see "Add Comment" 
When I follow "Add Comment" 
Then I fill in "comment" with "I loved this!"
And I press "Add comment" 
Then I should see "Comment created!" 