@bookmarks
Feature: Private bookmarks
  In order to have an archive full of bookmarks
  As a humble user
  I want to bookmark some works privately
      
  Scenario: private bookmarks on public and restricted works
# TODO
# check their visibility on a tag's bookmarks
# private bookmarks should also not increase a bookmark's counter

    Given the following activated users exist
      | login           | password   |
      | workauthor      | password   |
      | bookmarker      | password   |
      | otheruser       | password   |
      And a fandom exists with name: "Stargate SG-1", canonical: true
      And I am logged in as "workauthor" with password "password"
      And I post the locked work "Secret Masterpiece"
      And I post the work "Public Masterpiece"
    When I log out
      And I am logged in as "bookmarker" with password "password"
      And I view the work "Secret Masterpiece"
      And I follow "Bookmark"
      And I check "bookmark_rec"
      And I check "bookmark_private"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should see the "title" text "Restricted"
      And I should not see "Rec"
      And I should see "Private Bookmark"
      And I should see "0"
    When I view the work "Public Masterpiece"
      And I follow "Bookmark"
      And I check "bookmark_rec"
      And I check "bookmark_private"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should not see the "title" text "Restricted"
      And I should not see "Rec"
      And I should see "Private Bookmark"
      And I should see "0"
    
    # Private bookmarks should not show on the main bookmark page, but should show on your own bookmark page
    
    When I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
    When I am on bookmarker's bookmarks page
    #And show me the page
      And I should see "2 Bookmarks by bookmarker"
    Then I should see "Public Masterpiece"
      And I should see "Secret Masterpiece"
      
    # Private bookmarks should not be visible when logged out
    
    When I log out
      And I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
      And I should not see "bookmarker"
    When I go to bookmarker's bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
#    When I go to the works page
#    Then I should not see "Secret Masterpiece"
#      And I should see "Public Masterpiece"
#      And I should not see "Bookmarks:"
#      And I should not see "Bookmarks: 1"
    When I view the work "Public Masterpiece"
    Then I should not see "Bookmarks:"
      And I should not see "Bookmarks:1"
      
    # Private bookmarks should not be visible to other users
    
    When I am logged in as "otheruser" with password "password"
      And I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
    When I go to bookmarker's bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
    When I go to the works page
    Then I should see "Public Masterpiece"
      And I should not see "Secret Masterpiece"
      And I should not see "Bookmarks:"
      And I should not see "Bookmarks: 1"
      
    # Private bookmarks should not be visible even to the author
    
    When I log out
      And I am logged in as "workauthor" with password "password"
      And I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
    When I go to bookmarker's bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"

    # Private bookmarks should not be visible when logged out, even if there are other bookmarks on that work
    When I am logged in as "otheruser" with password "password"
      And I view the work "Public Masterpiece"
      And I follow "Bookmark"
      And I check "bookmark_rec"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
    When I log out
      And I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should see "Public Masterpiece"
      And I should not see "bookmarker"
      And I should see "otheruser"
      # And I should see "Bookmarked 1 time"
      And I should not see "Bookmarked 2 times"
    When I go to bookmarker's bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
    When I go to the works page
    Then I should not see "Secret Masterpiece"
      And I should see "Public Masterpiece"
      And I should not see "Bookmarks: 2"
      And I should see "Bookmarks: 1"
    When I view the work "Public Masterpiece"
    Then I should not see "Bookmarks:2"
      And I should see "Bookmarks:1"
    When I follow "1"
    Then I should see "List of Bookmarks"
      And I should see "Public Masterpiece"
      And I should see "otheruser"
      And I should not see "bookmarker"
