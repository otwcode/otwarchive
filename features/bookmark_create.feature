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
    When I go to bookmarkuser2's user page
    Then I should see "There are no works or bookmarks under this name yet"
    When I follow "bookmarkuser1"
    Then I should see "My Dashboard"
      And I should see "You don't have anything posted under this name yet"
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
    Then I should see "New bookmark for Revenge of the Sith"
      And I should see "Back to My Bookmarks"
    When I fill in "bookmark_notes" with "I liked this story"
      And I fill in "bookmark_tag_string" with " This is a tag, and another tag,"
      And I check "bookmark_rec"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should see "Back to Bookmarks"
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
      And I should not see "You don't have anything posted under this name yet"
      And I should see "Revenge of the Sith"
    When I edit the bookmark for "Revenge of the Sith"
    Then I should see "Editing bookmark for Revenge of the Sith"
      And I should see "Show"
      And I should see "Back to My Bookmarks"
    When I check "bookmark_private"
      And I press "Update"
    Then I should see "Bookmark was successfully updated"
    When I go to the bookmarks page
    Then I should not see "I liked this story"
    When I go to bookmarkuser1's bookmarks page
    Then I should see "I liked this story"
    
    # adding a new bookmark for the same work, check that everything functions as it should
    When I follow "Edit"
      And I follow "Add a new bookmark for this item"
      And I fill in "Your Notes" with "Did I mention I love this?"
      And I press "Create"
    Then I should see "Bookmark was successfully created."
      And I should see "Bookmarked 1 time"
    When I go to bookmarkuser2's works page
    Then I should see "Bookmarks: 1"
    When I view the work "Revenge of the Sith"
      And I follow "Edit/Add Bookmark"
    Then I should see "You have saved multiple bookmarks for this item"
    
    # privacy check for the private bookmark '
    When I follow "Log out"
      And I am logged in as "bookmarkuser2" with password "password"
      And I go to the bookmarks page
    Then I should not see "I liked this story"
    When I go to bookmarkuser1's user page
    Then I should not see "I liked this story"
    
  @bookmark_fandom_error
  Scenario: Create a bookmark on an external work (fandom error)
    Given the following activated users exist
      | login           | password   |
      | bookmarkuser1   | password   |
      And I am logged in as "bookmarkuser1" with password "password"
    When I go to bookmarkuser1's bookmarks page
    Then I should not see "Stuck with You"
    When I follow "Bookmark External Work"
      And I fill in "bookmark_external_author" with "Sidra"
      And I fill in "bookmark_external_title" with "Stuck with You"
      And I fill in "bookmark_external_url" with "http://test.sidrasue.com/short.html"
      And I press "Create"
    Then I should see "Fandom tag is required"
    When I fill in "bookmark_external_fandom_string" with "Popslash"
      And I press "Create"
    Then I should see "this work is not hosted on the Archive"
    When I go to bookmarkuser1's bookmarks page
    Then I should see "Stuck with You"
  @bookmark_url_error
  Scenario: Create a bookmark on an external work (url error)
    Given the following activated users exist
      | login           | password   |
      | bookmarkuser1   | password   |
      And I am logged in as "bookmarkuser1" with password "password"
    When I go to bookmarkuser1's bookmarks page
    Then I should not see "Stuck with You"
    When I follow "Bookmark External Work"
      And I fill in "bookmark_external_author" with "Sidra"
      And I fill in "bookmark_external_title" with "Stuck with You"
      And I fill in "bookmark_external_fandom_string" with "Popslash"
      And I press "Create"
    Then I should see "does not appear to be a valid URL"
    When I fill in "bookmark_external_url" with "http://test.sidrasue.com/short.html"
      And I press "Create"
    Then I should see "this work is not hosted on the Archive"
    When I go to bookmarkuser1's bookmarks page
    Then I should see "Stuck with You"
    
    # edit external bookmark, add a new one for the same work '
    When I follow "Edit"
    Then I should see "Editing bookmark for Stuck with You"
    When I fill in "Your Notes" with "I wish this author would join AO3"
      And I fill in "Your Tags" with "WIP"
      And I press "Update"
    Then I should see "Bookmark was successfully updated"
    When I follow "Edit"
      And I follow "Add a new bookmark for this item"
      And I fill in "Your Notes" with "Did I mention I love this?"
      And I press "Create"
    Then I should see "Bookmark was successfully created."
      And I should see "Bookmarked 2 times"
    When I follow "Edit"
      And I follow "Stuck with You"
    Then I should see "Stuck with You by Sidra"
      And I should see "Bookmarks: 2"
      
  Scenario: Create bookmarks and recs on restricted works, check how they behave from various access points
    Given the following activated users exist
      | login           | password   |
      | bookmarkuser1   | password   |
      | bookmarkuser2   | password   |
      And a fandom exists with name: "Stargate SG-1", canonical: true
      And I am logged in as "bookmarkuser1" with password "password"
      And I post the locked work "Secret Masterpiece"
      And I post the locked work "Mystery"
      And I post the work "Public Masterpiece"
      And I post the work "Publicky"
    When I follow "Log out"
      And I am logged in as "bookmarkuser2" with password "password"
      And I view the work "Secret Masterpiece"
      And I follow "Bookmark"
      And I check "bookmark_rec"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should see the "title" text "Restricted Work"
      And I should see the "title" text "Rec"
    When I view the work "Public Masterpiece"
      And I follow "Bookmark"
      And I check "bookmark_rec"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should not see the "title" text "Restricted Work"
    When I view the work "Mystery"
      And I follow "Bookmark"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should not see the "title" text "Rec"
    When I view the work "Publicky"
      And I follow "Bookmark"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
    When I go to the bookmarks page
    Then I should see "Secret Masterpiece"
    When I follow "Log out"
      And I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Mystery"
      But I should see "Public Masterpiece"
      And I should see "Publicky"
    When I follow "View Recs Only"
    Then I should see "Public Masterpiece"
      But I should not see "Publicky"
    When I go to bookmarkuser2's bookmarks page
    Then I should not see "Secret Masterpiece"
    When I am logged in as "bookmarkuser1" with password "password"
      And I go to bookmarkuser2's bookmarks page
    Then I should see "Secret Masterpiece"
    When I go to the bookmarks page
    Then I should see "Secret Masterpiece"
      And I should see "Mystery"
      And I should see "Public Masterpiece"
      And I should see "Publicky"
    When I follow "View Recs Only"
    Then I should see "Secret Masterpiece"
      But I should not see "Mystery"
      And I should see "Public Masterpiece"
      But I should not see "Publicky"
    When I go to the bookmarks page
    Then I should see "Stargate SG-1"
      And I should see "Secret Masterpiece"
      And I should see "Mystery"
      And I should see "Public Masterpiece"
      And I should see "Publicky"
    When I am logged out
      And I go to the bookmarks page
    Then I should see "Stargate SG-1"
      And I should not see "Secret Masterpiece"
      And I should not see "Mystery"
      But I should see "Public Masterpiece"
      And I should see "Publicky"

Scenario: extra commas in bookmark form (Issue 2284)

  Given I am logged in as "bookmarkuser" with password "password"
    And I post the work "Some Work"
  When I follow "Bookmark"
    And I fill in "Your Tags" with "Good tag, ,, also good tag, "
    And I press "Create"
  Then I should see "created"
