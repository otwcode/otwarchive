@comments
Feature: Delete a comment
  In order to remove a comment from public view
  As a user
  I want to be able to delete a comment I added
  As an author
  I want to be able to delete a comment a reader added to my work
  
  Scenario: User deletes a comment they added to a work
    When I am logged in as "author"
      And I post the work "Awesome story"
    When I am logged in as "commenter"
      And I post the comment "Fail comment" on the work "Awesome story"
      And I delete the comment
    Then I should see "Comment deleted."
    
  Scenario: User deletes a comment they added to a work and which is the parent of another comment
    When I am logged in as "author"
      And I post the work "Awesome story"
    When I am logged in as "commenter1"
      And I post the comment "Fail comment" on the work "Awesome story"
      And I reply to a comment with "I didn't mean that"
      And I delete the comment
    Then I should see "Comment deleted."
      And I should see "(Previous comment deleted.)"
      And I should see "I didn't mean that"
      
  Scenario: Author deletes a comment another user added to their work
    When I am logged in as "author"
      And I post the work "Awesome story"
    When I am logged in as "commenter"
      And I post the comment "Fail comment" on the work "Awesome story"
    When I am logged in as "author"
      And I view the work "Awesome story" with comments
      And I delete the comment
    Then I should see "Comment deleted."
    
  Scenario: Author deletes a parent comment that another user added to their work
    When I am logged in as "author"
      And I post the work "Awesome story"
    When I am logged in as "commenter"
      And I post the comment "Fail comment" on the work "Awesome story"
      And I reply to a comment with "I didn't mean that"
    When I am logged in as "author"
      And I view the work "Awesome story" with comments
      And I delete the comment
    Then I should see "Comment deleted."
      And I should see "(Previous comment deleted.)"
      And I should see "I didn't mean that"
  
