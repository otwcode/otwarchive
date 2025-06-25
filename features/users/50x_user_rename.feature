@users
Feature: User rename
  Scenario: Changing username updates chapter bylines
    Given the work "Title" by "pikachu" with chapter two co-authored with "before"
      And I am logged in as "before" with password "password"
      And I post a chapter for the work "Title"
    When I view the work "Title"
      And I view the 3rd chapter
    Then I should see "Chapter by before"
    When I visit the change username page for before
      And I fill in "New username" with "after"
      And I fill in "Password" with "password"
      And I press "Change Username"
    Then I should see "Your username has been successfully updated."
    When I view the work "Title"
      And it is currently 1 second from now
      And I view the 3rd chapter
    Then I should see "Chapter by after"
