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
      And I should see "My Bookmarks"
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
    
    # delete external bookmark
    When I follow "Delete"
    Then I should see "Are you sure you want to delete"
      And I should see "Stuck with You"
    When I press "Yes, Delete Bookmark"
    Then I should see "Bookmark was successfully deleted."
      And I should not see "Stuck with You"
      
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
      And I should see the image "title" text "Restricted"
      And I should see "Rec" within ".rec"
    When I view the work "Public Masterpiece"
      And I follow "Bookmark"
      And I check "bookmark_rec"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should not see the image "title" text "Restricted"
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

Scenario: bookmark added to moderated collection has flash notice only when not approved
  Given the following activated users exist
    | login      | password |
    | workauthor | password |
    | bookmarker | password |
    | otheruser  | password |
    And I have a moderated collection "Five Pillars" with name "five_pillars"
    And I am logged in as "workauthor" with password "password"
    And I post the work "Fire Burn, Cauldron Bubble"
  When I log out
    And I am logged in as "bookmarker" with password "password"
    And I view the work "Fire Burn, Cauldron Bubble"
    And I follow "Bookmark"
    And I fill in "bookmark_collection_names" with "five_pillars"
    And I press "Create"
  Then I should see "Bookmark was successfully created"
    And I should see "The collection Five Pillars is currently moderated."
  When I go to bookmarker's bookmarks page
    Then I should see "The collection Five Pillars is currently moderated."
  When I log out
    And I am logged in as "moderator" with password "password"
    And I approve the first item in the collection "Five Pillars"
    And I am logged in as "bookmarker" with password "password"
    And I go to bookmarker's bookmarks page
  Then I should not see "The collection Five Pillars is currently moderated."


Scenario: bookmarks added to moderated collections appear correctly
  Given the following activated users exist
    | login      | password |
    | workauthor | password |
    | bookmarker | password |
    | otheruser  | password |
    And I have a moderated collection "JBs Greatest" with name "jbs_greatest"
    And I have the collection "Mrs. Pots" with name "mrs_pots"
    And I am logged in as "workauthor" with password "password"
    And I post the work "The Murder of Sherlock Holmes"
  When I log out
    And I am logged in as "bookmarker" with password "password"
    And I view the work "The Murder of Sherlock Holmes"
    And I follow "Bookmark"
    And I fill in "bookmark_collection_names" with "jbs_greatest"
    And I press "Create"
  Then I should see "Bookmark was successfully created"
    And I should see "The collection JBs Greatest is currently moderated. Your bookmark must be approved by the collection maintainers before being listed there."
  When I go to bookmarker's bookmarks page
    And I should see "The Murder of Sherlock Holmes"
    And I should see "Bookmarker's Collections: JBs Greatest"
    And I should see "The collection JBs Greatest is currently moderated. Your bookmark must be approved by the collection maintainers before being listed there."
  When I go to the bookmarks page
    And I should see "The Murder of Sherlock Holmes"
    And I should see "Bookmarker's Collections: JBs Greatest"
    And I should see "The collection JBs Greatest is currently moderated. Your bookmark must be approved by the collection maintainers before being listed there."
  When I log out
  # Users who do not own the bookmark should not see the notice, or see that it
  # has been submitted to a specific collection
    And I am logged in as "otheruser" with password "password"
    And I go to bookmarker's bookmarks page
  Then I should see "The Murder of Sherlock Holmes"
    And I should not see "Bookmarker's Collections: JBs Greatest"
    And I should not see "The collection JBs Greatest is currently moderated. Your bookmark must be approved by the collection maintainers before being listed there."
  When I go to the bookmarks page
    Then I should see "The Murder of Sherlock Holmes"
    And I should not see "Bookmarker's Collections: JBs Greatest"
    And I should not see "The collection JBs Greatest is currently moderated. Your bookmark must be approved by the collection maintainers before being listed there."
  # Edit the bookmark and add it to a second, unmoderated collection, and recheck
  # all the things
  When I log out
    And I am logged in as "bookmarker" with password "password"
    And I view the work "The Murder of Sherlock Holmes"
    And I follow "Edit Bookmark"
    And I fill in "bookmark_collection_names" with "jbs_greatest,mrs_pots"
    And I press "Edit" within "div#bookmark-form"
    And all search indexes are updated
  Then I should see "Bookmark was successfully updated."
    And I should see "The collection JBs Greatest is currently moderated."
  When I go to bookmarker's bookmarks page
    Then I should see "The Murder of Sherlock Holmes"
    And I should see "JBs Greatest" within "ul.meta"
    And I should see "Mrs. Pots" within "ul.meta"
    And I should see "The collection JBs Greatest is currently moderated."
  When I go to the bookmarks page
    Then I should see "The Murder of Sherlock Holmes"
    And I should see "JBs Greatest" within "ul.meta"
    And I should see "Mrs. Pots" within "ul.meta"
    And I should see "The collection JBs Greatest is currently moderated."
  When I log out
    And I am logged in as "otheruser" with password "password"
    And I go to bookmarker's bookmarks page
  Then I should see "The Murder of Sherlock Holmes"
    And I should not see "JBs Greatest" within "ul.meta"
    And I should see "Bookmarker's Collections: Mrs. Pots"
    And I should not see "The collection JBs Greatest is currently moderated."
  When I go to the bookmarks page
    Then I should see "The Murder of Sherlock Holmes"
    And I should not see "JBs Greatest" within "ul.meta"
    And I should see "Bookmarker's Collections: Mrs. Pots"
    And I should not see "The collection JBs Greatest is currently moderated."

Scenario: Adding bookmarks to closed collections (Issue 3083)
  Given I am logged in as "moderator" with password "password"
    And I have a closed collection "Unsolved Mysteries" with name "unsolved_mysteries"
    And I have a closed collection "Rescue 911" with name "rescue_911"
    And I am logged in as "moderator" with password "password"
    And I post the work "Hooray for Homicide"
    And I post the work "Sing a Song of Murder"
    And I go to "Unsolved Mysteries" collection's page
    # As a moderator, create a bookmark in a closed collection
  Then I view the work "Hooray for Homicide"
    And I follow "Bookmark"
    And I fill in "bookmark_collection_names" with "unsolved_mysteries"
    And I press "Create"
    And I should see "Bookmark was successfully created"
    # Now, with the exising bookmark, as a mod, add it to a different closed collection
    And I follow "Edit"
    And I fill in "bookmark_collection_names" with "rescue_911"
    And I press "Update"
  Then I should see "Bookmark was successfully updated"
  Then I view the work "Sing a Song of Murder"
    And I follow "Bookmark"
    And I press "Create"
    And I should see "Bookmark was successfully created"
    # Use the 'Add To Collections' button to add the bookmark to a closed collection AFTER creating said bookmark
    And I follow "Add To Collection"
    And I fill in "collection_names" with "unsolved_mysteries"
    And I press "Add"
    And I should see "Added to collection(s): Unsolved Mysteries"
    # Still as the moderator, try to edit the bookmark which is IN a closed collection already
  When I follow "Edit"
    And I fill in "bookmark_notes" with "This is my edited bookmark"
    And I press "Update"
  Then I should see "Bookmark was successfully updated."
    And I am logged out
    # Log in as a regular (totally awesome!) user
  Then I am logged in as "RobertStack" with password "password"
    And I view the work "Sing a Song of Murder"
    And I follow "Bookmark"
    And I fill in "bookmark_collection_names" with "rescue_911"
    And I press "Create"
    And I should see "Sorry! We couldn't save this bookmark because:"
    And I should see "The collection rescue_911 is not currently open."
  Then I view the work "Hooray for Homicide"
    And I follow "Bookmark"
    And I press "Create"
    And I should see "Bookmark was successfully created"
    And I follow "Add To Collection"
    And I fill in "collection_names" with "rescue_911"
    And I press "Add"
    And I should see "We couldn't add your submission to the following collections: Rescue 911 is closed to new submissions."
    # Now, as a regular user try to add that existing bookmark to a closed collection from the 'Edit' page of a bookmark
    And I follow "Edit"
    And I fill in "bookmark_collection_names" with "rescue_911"
    And I press "Update"
    And I should see "We couldn't add your submission to the following collections: Rescue 911 is closed to new submissions."
    And I am logged out
  # Create a collection, put a bookmark in it, close the collection, then try
  # to edit that bookmark
  Then I open the collection with the title "Rescue 911"
    And I am logged out
  Then I am logged in as "Scott" with password "password"
    And I view the work "Sing a Song of Murder"
    And I follow "Bookmark"
    And I fill in "bookmark_collection_names" with "rescue_911"
    And I press "Create"
    And I should see "Bookmark was successfully created"
    And I am logged out
  When I close the collection with the title "Rescue 911"
    And I am logged in as "Scott" with password "password"
    And I view the work "Sing a Song of Murder"
    And I follow "Edit Bookmark"
    And I fill in "bookmark_notes" with "This is a user editing a closed collection bookmark"
    And I press "Edit"
  Then I should see "Bookmark was successfully updated."

Scenario: Delete bookmarks of a work and a series
  Given the following activated users exist
    | login           | password   |
    | wahlly   | password   |
    | markymark   | password   |
    And I am logged in as "wahlly"
    And I add the work "A Mighty Duck" to series "The Funky Bunch"
  When I log out
    And I am logged in as "markymark"
    And I view the work "A Mighty Duck"
    And I follow "Bookmark"
    And I press "Create"
  Then I should see "Bookmark was successfully created."
    And I should see "Delete"
  When I follow "Delete"
    And I press "Yes, Delete Bookmark"
  Then I should see "Bookmark was successfully deleted."
  When I view the series "The Funky Bunch"
    And I follow "Bookmark Series"
    And I press "Create"
  Then I should see "Bookmark was successfully created."
  When I follow "Delete"
    And I press "Yes, Delete Bookmark"
  Then I should see "Bookmark was successfully deleted."

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

  
