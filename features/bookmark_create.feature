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
    Then I should see "Hi, bookmarkuser1!"
    When I follow "bookmarkuser1"
    Then I should see "My Dashboard"
      And I should see "There are no works or bookmarks under this name yet"
      And I should not see "Revenge of the Sith"
    When I follow "Log out"
    Then I should see "logged out"
    When I am logged in as "bookmarkuser2" with password "password"
      And I post the work "Revenge of the Sith"
    When I go to the bookmarks page
    Then I should not see "Revenge of the Sith"
    When I am logged out
      And I am logged in as "bookmarkuser1" with password "password"
    When I go to the works page
    Then I should see "Revenge of the Sith"
    When I follow "Revenge of the Sith"
    Then I should see "Bookmark"
    When I follow "Bookmark"
    Then I should see "Add a new bookmark"
    When I fill in "bookmark_notes" with "I liked this story"
      And I fill in "bookmark_tag_string" with " This is a tag, and another tag,"
      And I check "bookmark_rec"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
    When I follow "Log out"
      And I am logged in as "bookmarkuser2" with password "password"
      And I go to the bookmarks page
    Then I should see "Revenge of the Sith"
      And I should see " This is a tag, and another tag"
      And I should see "I liked this story"
    When I follow "Log out"
      And I am logged in as "bookmarkuser1" with password "password"
      And I follow "bookmarkuser1"
    Then I should see "My Dashboard"
      And I should not see "There are no works or bookmarks under this name yet"
      And I should see "Revenge of the Sith"
    When I edit the bookmark for "Revenge of the Sith"
    Then I should see "Editing bookmark"
    When I check "bookmark_private"
      And I press "Update"
    Then I should see "Bookmark was successfully updated"
    When I go to the bookmarks page
    Then I should not see "I liked this story"
    When I go to bookmarkuser1's user page
    Then I should see "I liked this story"
    When I follow "Log out"
      And I am logged in as "bookmarkuser2" with password "password"
      And I go to the bookmarks page
    Then I should not see "I liked this story"
    When I go to bookmarkuser1's user page
    Then I should not see "I liked this story"

  Scenario: Create a bookmark on an external work
    Given the following activated users exist
      | login           | password   |
      | bookmarkuser1   | password   |
      And I am logged in as "bookmarkuser1" with password "password"
    When I go to bookmarkuser1's bookmarks page
    Then I should not see "Stuck with You"
    When I follow "Bookmark External Work"
      And I fill in "bookmark_external_url" with "http://sidra.livejournal.com/2379.html" 
      And I fill in "bookmark_external_author" with "Sidra"
      And I fill in "bookmark_external_title" with "Stuck with You"
      And I press "Create"
    Then I should see "Fandom tag is required"
      When I fill in "bookmark_external_fandom_string" with "Popslash"
    And I press "Create"
    Then I should see "this work is not hosted on the Archive"
    When I go to bookmarkuser1's bookmarks page
    Then I should see "Stuck with You"
