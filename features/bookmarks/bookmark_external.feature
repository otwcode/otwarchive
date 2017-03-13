@bookmarks
Feature: Create bookmarks of external works
  In order to have an archive full of bookmarks
  As a humble user
  I want to bookmark some works

  @bookmark_fandom_error
  Scenario: Create a bookmark on an external work (fandom error)
    Given basic tags
      And I am logged in as "first_bookmark_user"
    When I go to first_bookmark_user's bookmarks page
    Then I should not see "Stuck with You"
    When I follow "Bookmark External Work"
      And I fill in "bookmark_external_author" with "Sidra"
      And I fill in "bookmark_external_title" with "Stuck with You"
      And I fill in "bookmark_external_url" with "http://test.sidrasue.com/short.html"
      And I press "Create"
    Then I should see "Fandom tag is required"
    When I fill in "bookmark_external_fandom_string" with "Popslash"
      And I press "Create"
    Then I should see "This work isn't hosted on the Archive"
    When I go to first_bookmark_user's bookmarks page
    Then I should see "Stuck with You"

  @bookmark_url_error
  Scenario: Create a bookmark on an external work (url error)
    Given the following activated users exist
      | login           | password   |
      | first_bookmark_user   | password   |
      And I am logged in as "first_bookmark_user"
      And the default ratings exist
    When I go to first_bookmark_user's bookmarks page
    Then I should not see "Stuck with You"
    When I follow "Bookmark External Work"
      And I fill in "bookmark_external_author" with "Sidra"
      And I fill in "bookmark_external_title" with "Stuck with You"
      And I fill in "bookmark_external_fandom_string" with "Popslash"
      And I press "Create"
    Then I should see "does not appear to be a valid URL"
    When I fill in "bookmark_external_url" with "http://test.sidrasue.com/short.html"
      And I press "Create"
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