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
      And I set my preferences to receive copies of my own comments
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
      And I set my preferences to receive copies of my own comments
      And I comment on an admin post
      And all emails have been delivered
    When I edit a comment
    Then 1 email should be delivered to "narcis"
