@bookmarks
Feature: Create bookmarks
  In order to have an archive full of bookmarks
  As a humble user
  I want to bookmark some works
    
  Scenario: Create a bookmark
    Given the following activated users exist
      | login           | password   |
      | bookmarkuser1   | password   |
      | bookmarkuser2   | password   |
      And I am logged in as "bookmarkuser1" with password "password"
      And a warning exists with name: "No Warnings", canonical: true
		Then I should see "Hi, bookmarkuser1!"
      And I should see "Log out"
		When I follow "bookmarkuser1"
    Then I should see "My Dashboard"
      And I should see "There are no works or bookmarks under this name yet"
    When I follow "Log out"
    Then I should see "logged out"
    When I am logged in as "bookmarkuser2" with password "password"
		Then I should see "Hi, bookmarkuser2!"
    And I should see "Log out"
    When I go to the new work page
		And I select "Not Rated" from "Rating"
		And I check "No Warnings"
		And I fill in "Fandoms" with "Stargate SG-1"
		And I fill in "Work Title" with "Revenge of the Sith"
		And I fill in "content" with "That could be an amusing crossover."
		When I press "Preview"
		Then I should see "Preview Work"
		When I press "Post"
		Then I should see "Work was successfully posted."
		When I go to the works page
		Then I should see "Revenge of the Sith"
    When I follow "Log out"
    Then I should see "logged out"
    When I am logged in as "bookmarkuser1" with password "password"
    And I go to the works page
    Then I should see "Revenge of the Sith"
    When I follow "Revenge of the Sith"
    Then I should see "Bookmark"
    When I follow "Bookmark"
    Then I should see "Add a new bookmark"