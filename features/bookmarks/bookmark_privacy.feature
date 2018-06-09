@bookmarks
Feature: Private bookmarks
  In order to have an archive full of bookmarks
  As a humble user
  I want to bookmark some works privately

  @disable_caching
  Scenario: private bookmarks on public and restricted works

    Given the following activated users exist
      | login                |
      | workauthor           |
      | avid_bookmarker      |
      | otheruser            |
      And a fandom exists with name: "Stargate SG-1", canonical: true
      And I am logged in as "workauthor"
      And I post the locked work "Secret Masterpiece"
      And I post the work "Public Masterpiece"
    When I am logged in as "avid_bookmarker"
      And I view the work "Secret Masterpiece"
      And I follow "Bookmark"
      And I check "bookmark_rec"
      And I check "bookmark_private"
      And I press "Create"
    Then I should see "Bookmark was successfully created"
      And I should see the image "title" text "Restricted"
      And I should not see "Rec"
      And I should see "Private Bookmark"
      And I should see "0"
    When I view the work "Public Masterpiece"
      And I follow "Bookmark"
      And I check "bookmark_rec"
      And I check "bookmark_private"
      And I press "Create"
      And all indexing jobs have been run
    Then I should see "Bookmark was successfully created"
      And I should not see the image "title" text "Restricted"
      And I should not see "Rec"
      And I should see "Private Bookmark"
      And I should see "0"

    # Private bookmarks should not show on the main bookmark page, but should show on your own bookmark page

    When I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
    When I am on avid_bookmarker's bookmarks page
    Then I should see "2 Bookmarks by avid_bookmarker"
      And I should see "Public Masterpiece"
      And I should see "Secret Masterpiece"

    # Private bookmarks should not be visible when logged out

    When I log out
      And I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
      And I should not see "avid_bookmarker"
    When I go to avid_bookmarker's bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
    When I go to the works page
    Then I should not see "Secret Masterpiece"
      And I should see "Public Masterpiece"
      And I should not see "Bookmarks:"
      And I should not see "Bookmarks: 1"
    When I view the work "Public Masterpiece"
    Then I should not see "Bookmarks:"
      And I should not see "Bookmarks:1"

    # Private bookmarks should not be visible to other users

    When I am logged in as "otheruser"
      And I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
    When I go to avid_bookmarker's bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
    When I go to the works page
    Then I should see "Public Masterpiece"
      And I should not see "Secret Masterpiece"
      And I should not see "Bookmarks:"
      And I should not see "Bookmarks: 1"

    # Private bookmarks should not be visible even to the author

    When I am logged in as "workauthor"
      And I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"
    When I go to avid_bookmarker's bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should not see "Public Masterpiece"

    # Private bookmarks should not be visible when logged out, even if there are other bookmarks on that work
    When I am logged in as "otheruser"
      And I view the work "Public Masterpiece"
      And I rec the current work
      And all indexing jobs have been run
    When I log out
      And I go to the bookmarks page
    Then I should not see "Secret Masterpiece"
      And I should see "Public Masterpiece"
      And I should not see "avid_bookmarker"
      And I should see "otheruser"
    When I go to avid_bookmarker's bookmarks page
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
      And I should not see "avid_bookmarker"

    # Private bookmarks should not show on tag's page
    When I go to the bookmarks tagged "Stargate SG-1"
    Then I should not see "Secret Masterpiece"
      And I should see "Public Masterpiece"
      And I should not see "avid_bookmarker"
      And I should see "otheruser"
      # This *should* be 1, because there's no way for a bookmark to appear on
      # a tag bookmark page if the bookmarkable has a public_bookmark_count of
      # 0. However, caching means that this is actually 0:
      And I should see "0" within ".count"
      And I should not see "2" within ".count"
