@bookmarks
Feature: Create bookmarks of external works
  In order to have an archive full of bookmarks
  As a humble user
  I want to bookmark some works

  Scenario: A user can bookmark an external work using all the Creator's Tags fields (fandoms, rating, category, relationships, character)
    Given basic tags
      And mock websites with no content
      And I am logged in as "bookmarker"
      And I am on the new external work page
    When I fill in "URL" with "http://example.org/200"
      And I fill in "Creator" with "ao3testing"
      And I fill in "Title" with "Some External Work"
      And I fill in "Fandoms" with "Test Fandom"
      And I select "General Audiences" from "Rating"
      And I check "M/M"
      And I fill in "Relationships" with "Character 1/Character 2"
      And I fill in "Characters" with "Character 3, Character 4"
      And I press "Create"
    Then I should see "Bookmark was successfully created."
      And I should see "Some External Work"
      And I should see "ao3testing"
      And I should see "Test Fandom"
      And I should see "General Audiences"
      And I should see "M/M"
      And I should see "Character 1/Character 2"
      And I should see "Character 3"
      And I should see "Character 4"

  Scenario: A user must enter a fandom to create a bookmark on an external work
    Given basic tags
      And mock websites with no content
      And I am logged in as "first_bookmark_user"
    When I go to first_bookmark_user's bookmarks page
    Then I should not see "Stuck with You"
    When I follow "Bookmark External Work"
      And I fill in "Creator" with "Sidra"
      And I fill in "Title" with "Stuck with You"
      And I fill in "URL" with "http://example.org/200"
      And I press "Create"
    Then I should see "Fandom tag is required"
    When I fill in "Fandoms" with "Popslash"
      And I press "Create"
      And all indexing jobs have been run
    Then I should see "This work isn't hosted on the Archive"
    When I go to first_bookmark_user's bookmarks page
    Then I should see "Stuck with You"

  Scenario: A user must enter a valid URL to create a bookmark on an external work
    Given I am logged in as "first_bookmark_user"
      And the default ratings exist
      And mock websites with no content
    When I go to first_bookmark_user's bookmarks page
    Then I should not see "Stuck with You"
    When I follow "Bookmark External Work"
      And I fill in "Creator" with "Sidra"
      And I fill in "Title" with "Stuck with You"
      And I fill in "Fandoms" with "Popslash"
      And I press "Create"
    Then I should see "does not appear to be a valid URL"
    When I fill in "URL" with "http://example.org/200"
      And I press "Create"
      And all indexing jobs have been run
    Then I should see "This work isn't hosted on the Archive"
    When I go to first_bookmark_user's bookmarks page
    Then I should see "Stuck with You"

    # edit external bookmark
    When I follow "Edit"
    Then I should see "Editing bookmark for Stuck with You"
    When I fill in "Notes" with "I wish this author would join AO3"
      And I fill in "Your tags" with "WIP"
      And I press "Update"
    Then I should see "Bookmark was successfully updated"

    # delete external bookmark
    When I follow "Delete"
    Then I should see "Are you sure you want to delete"
      And I should see "Stuck with You"
    When I press "Yes, Delete Bookmark"
    Then I should see "Bookmark was successfully deleted."
      And I should not see "Stuck with You"

  Scenario: Bookmark External Work link should be available to logged in users, but not logged out users
    Given a fandom exists with name: "Testing BEW Button", canonical: true
      And I am logged in as "markie" with password "theunicorn"
      And I create the collection "Testing BEW Collection"
    When I go to my bookmarks page
    Then I should see "Bookmark External Work"
    When I go to the bookmarks page
    Then I should see "Bookmark External Work"
    When I go to the bookmarks in collection "Testing BEW Collection"
    Then I should see "Bookmark External Work"
    When I log out
      And I go to markie's bookmarks page
    Then I should not see "Bookmark External Work"
    When I go to the bookmarks page
    Then I should not see "Bookmark External Work"
    When I go to the bookmarks tagged "Testing BEW Button"
    Then I should not see "Bookmark External Work"
    When I go to the bookmarks in collection "Testing BEW Collection"
    Then I should not see "Bookmark External Work"
