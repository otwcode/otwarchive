@comments
Feature: Commenting on admin posts
  As a user
  I want to comment on admin posts
  In order to communicate with admins and other users

  Scenario: Random user comments on an admin post
    Given I have posted an admin post
      And I am logged in as "regular"
      And all emails have been delivered
    When I comment on an admin post
    Then "regular" should not be emailed

  Scenario: A user who receives copies of their own comments comments on an admin post
    Given I have posted an admin post
      And I am logged in as "narcis"
      And I set my preferences to turn on copies of my own comments
      And all emails have been delivered
    When I comment on an admin post
    Then 1 email should be delivered to "narcis"

  Scenario: Random user edits a comment on an admin post
    Given I have posted an admin post
      And I am logged in as "regular"
      And I comment on an admin post
      And all emails have been delivered
    When I edit a comment
    Then "regular" should not be emailed

  Scenario: A user who receives copies of their own comments edits a comment on an admin post
    Given I have posted an admin post
      And I am logged in as "narcis"
      And I set my preferences to turn on copies of my own comments
      And I comment on an admin post
      And all emails have been delivered
    When I edit a comment
    Then 1 email should be delivered to "narcis"

  Scenario: Comment permissions on admin posts
    Given I have posted an admin post
      And I am logged in as a "communications" admin
    When I go to the admin-posts page
      And I follow "Edit"
    Then I should see "Who can comment on this work"
      And I should see "Registered users and guests can comment"
      And I should see "Only registered users can comment"
      And I should see "No one can comment"
    When I choose "No one can comment"
      And I press "Post"
      And I am logged in as "regular"
      And I go to the admin-posts page
      And follow "Comment"
    Then I should see "Sorry, this news post doesn't allow comments."

    When I am logged in as a "communications" admin
      And I go to the admin-posts page
      And I follow "Edit"
      And I choose "Only registered users can comment"
      And I press "Post"
    Then I should see "successfully updated"
    When I am logged in as "regular"
      And I go to the admin-posts page
      And follow "Comment"
      And I fill in "comment[comment_content]" with "Comment comment 1"
      And I press "Comment"
    Then I should see "Comment comment 1"
    When I am logged out
      And I go to the admin-posts page
      And follow "Comment"
    Then I should see "Sorry, this news post doesn't allow non-Archive users to comment."
      And I should see "You can however contact Support with any feedback or questions."
    When I follow "contact Support"
      Then I should be on the support page
