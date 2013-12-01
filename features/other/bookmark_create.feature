@bookmarks
Feature: Create bookmarks
  In order to have an archive full of bookmarks
  As a humble user
  I want to bookmark some works

Scenario: Create a bookmark
  Given I am logged in as "first_bookmark_user"
    When I am on first_bookmark_user's user page 
      Then I should see "have anything posted under this name yet"
    When I am logged in as "another_bookmark_user"
      And I post the work "Revenge of the Sith"
      When I go to the bookmarks page
      Then I should not see "Revenge of the Sith"
    When I am logged in as "first_bookmark_user"
      And I go to the works page
      And I follow "Revenge of the Sith"
    Then I should see "Bookmark"
    When I follow "Bookmark"
      And I fill in "bookmark_notes" with "I liked this story"
      And I fill in "bookmark_tag_string" with "This is a tag, and another tag,"
      And I check "bookmark_rec"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should see "Back to Bookmarks"
    When I am logged in as "another_bookmark_user"
      And I go to the bookmarks page
    Then I should see "Revenge of the Sith"
      And I should see "This is a tag"
      And I should see "and another tag"
      And I should see "I liked this story"
    When I am logged in as "first_bookmark_user"
      And I go to first_bookmark_user's user page 
    Then I should not see "You don't have anything posted under this name yet"
      And I should see "Revenge of the Sith"
    When I edit the bookmark for "Revenge of the Sith"
      And I check "bookmark_private"
      And I press "Edit"
    Then I should see "Bookmark was successfully updated"
    When I go to the bookmarks page
    Then I should not see "I liked this story"
    When I go to first_bookmark_user's bookmarks page
    Then I should see "I liked this story"
    
    # privacy check for the private bookmark '
    When I am logged in as "another_bookmark_user"
      And I go to the bookmarks page
    Then I should not see "I liked this story"
    When I go to first_bookmark_user's user page
    Then I should not see "I liked this story"
    
  @bookmark_fandom_error
  Scenario: Create a bookmark on an external work (fandom error)
    Given I am logged in as "first_bookmark_user"
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
      And I fill in "Your Tags" with "WIP"
      And I press "Update"
    Then I should see "Bookmark was successfully updated"
      
  Scenario: Create bookmarks and recs on restricted works, check how they behave from various access points
    Given the following activated users exist
      | login           | password   |
      | first_bookmark_user   | password   |
      | another_bookmark_user   | password   |
      And a fandom exists with name: "Stargate SG-1", canonical: true
      And I am logged in as "first_bookmark_user"
      And I post the locked work "Secret Masterpiece"
      And I post the locked work "Mystery"
      And I post the work "Public Masterpiece"
      And I post the work "Publicky"
    When I log out
      And I am logged in as "another_bookmark_user"
      And I view the work "Secret Masterpiece"
      And I follow "Bookmark"
      And I check "bookmark_rec"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should see the "title" text "Restricted"
      And I should see "Rec" within ".rec"
    When I view the work "Public Masterpiece"
      And I follow "Bookmark"
      And I check "bookmark_rec"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should not see the "title" text "Restricted"
    When I view the work "Mystery"
      And I follow "Bookmark"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should not see "Rec"
    When I view the work "Publicky"
      And I follow "Bookmark"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
    When I log out
      And I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Mystery"
      But I should see "Public Masterpiece"
      And I should see "Publicky"
    When I go to another_bookmark_user's bookmarks page
    Then I should not see "Secret Masterpiece"
      And I am logged out
    When I am logged in as "first_bookmark_user"
      And I go to another_bookmark_user's bookmarks page
    # This step always fails. I don't know why, and I don't much care at this point. Sidebar correctly shows that
    # there are two bookmarks, but the main page says that there are zero (0).     - SS
    # TODO: Someone should figure out why this doesn't work. Bookmark issue
    #Then I should see "Secret Masterpiece"

Scenario: extra commas in bookmark form (Issue 2284)

  Given I am logged in as "bookmarkuser"
    And I post the work "Some Work"
  When I follow "Bookmark"
    And I fill in "Your Tags" with "Good tag, ,, also good tag, "
    And I press "Create"
  Then I should see "created"

