@bookmarks
Feature: Create and edit bookmarks with javascript enabled
  In order to have a good user experience
  As a humble user
  I want to be able to create and edit bookmarks with javascript enabled
  
  Background:
    Given I am logged in as "recengine"
      And I bookmark the work "Bookmark: The Beginnings"
      And I bookmark the work "Bookmark: The Sequel"

  @javascript
  Scenario: The Bookmark button on a work's bookmark page correctly opens, closes, and reopens the form
  When I am logged out
    And I am logged in
    And I am on the bookmarks page for the work "Bookmark: The Beginnings"
    # Specify #main .navigation because the string and its plural form appear in a lot of places
    # Open
    And I follow "Bookmark" within "#main .navigation"
  Then I should see "save a bookmark!"
    And I should not see "Bookmark" within "#main .navigation"
  # Close 
  When I exit the bookmark form
  Then I should see "Bookmark" within "#main .navigation"
    And I should not see "save a bookmark!"
  # Reopen
  When I follow "Bookmark"
  Then I should see "save a bookmark!"
    And I should not see "Bookmark" within "#main .navigation"

  @javascript
  Scenario: The Edit Bookmark button on a work's bookmark page correctly opens, closes, and reopens the edit form
  When I am on the bookmarks page for the work "Bookmark: The Beginnings"
  # Open
    And I follow "Edit Bookmark"
  Then I should see "save a bookmark!"
    And I should not see "Edit Bookmark"
    # Specify .own .actions because the string has some text in common with Edit Bookmark
    And I should not see "Edit" within ".own .actions"
  # Close
  When I exit the bookmark form
  Then I should see "Edit Bookmark"
    And I should see "Edit" within ".own .actions"
  # Reopen
  When I follow "Edit"
  Then I should see "save a bookmark!"

  @javascript
  Scenario: The Edit button correctly opens, closes, and reopens edit forms when there are multiple bookmarks on a page
    When I am on the bookmarks page
      # Open
      And I follow "Edit" in the blurb for recengine's bookmark of "Bookmark: The Beginnings"
    Then the edit bookmark form should be open in the blurb for recengine's bookmark of "Bookmark: The Beginnings"
    When I follow "Edit" in the blurb for recengine's bookmark of "Bookmark: The Sequel"
    Then the edit bookmark form should be open in the blurb for recengine's bookmark of "Bookmark: The Sequel"
    # Close
    When I exit the bookmark form for the bookmark of "Bookmark: The Beginnings"
    Then the edit bookmark form should be closed in the blurb for recengine's bookmark of "Bookmark: The Beginnings"
    When I exit the bookmark form for the bookmark of "Bookmark: The Sequel"
    Then the edit bookmark form should be closed in the blurb for recengine's bookmark of "Bookmark: The Sequel"
    # Reopen
    When I follow "Edit" in the blurb for recengine's bookmark of "Bookmark: The Beginnings"
    Then the edit bookmark form should be open in the blurb for recengine's bookmark of "Bookmark: The Beginnings"

  @javascript 
  Scenario: The Saved button correctly opens, closes, and reopens edit forms when there are multiple bookmark blurbs on a page
    Given "bookmarker" has a bookmark of a work titled "Bookmark: The Beginnings"
      And "bookmarker" has a bookmark of a work titled "Bookmark: The Sequel"
      And I am logged out
      And I am logged in as "bookmarker"
      And I go to the bookmarks page
    # Open
    When I follow "Saved" in the blurb for recengine's bookmark of "Bookmark: The Beginnings"
    Then the edit bookmark form should be open in the blurb for bookmarker's bookmark of "Bookmark: The Beginnings"
    When I follow "Saved" in the blurb for recengine's bookmark of "Bookmark: The Sequel"
    Then the edit bookmark form should be open in the blurb for bookmarker's bookmark of "Bookmark: The Sequel"
    # Close
    When I exit the bookmark form for the bookmark of "Bookmark: The Beginnings"
    Then the edit bookmark form should be closed in the blurb for bookmarker's bookmark of "Bookmark: The Beginnings"
    When I exit the bookmark form for the bookmark of "Bookmark: The Sequel"
    Then the edit bookmark form should be closed in the blurb for bookmarker's bookmark of "Bookmark: The Sequel"
    # Reopen
    When I follow "Saved" in the blurb for recengine's bookmark of "Bookmark: The Beginnings"
    Then the edit bookmark form should be open in the blurb for bookmarker's bookmark of "Bookmark: The Beginnings"

  @javascript 
  Scenario: The Save button correctly opens, closes, and reopens edit forms when there are multiple bookmark blurbs on a page
    When I am logged out
      And I am logged in as "bookmarker"
      And I go to the bookmarks page
    # Open
    When I follow "Save" in the blurb for recengine's bookmark of "Bookmark: The Beginnings"
    Then the new bookmark form should be open in the blurb for recengine's bookmark of "Bookmark: The Beginnings"
    When I follow "Save" in the blurb for recengine's bookmark of "Bookmark: The Sequel"
    Then the new bookmark form should be open in the blurb for recengine's bookmark of "Bookmark: The Sequel"
    # Close
    When I exit the bookmark form for the bookmark of "Bookmark: The Beginnings"
    Then the new bookmark form should be closed in the blurb for recengine's bookmark of "Bookmark: The Beginnings"
    When I exit the bookmark form for the bookmark of "Bookmark: The Sequel"
    Then the new bookmark form should be closed in the blurb for recengine's bookmark of "Bookmark: The Sequel"
    # Reopen
    When I follow "Save" in the blurb for recengine's bookmark of "Bookmark: The Beginnings"
    Then the new bookmark form should be open in the blurb for recengine's bookmark of "Bookmark: The Beginnings"

  @javascript
  Scenario: The Saved button correctly opens, closes, and reopens edit forms when there are multiple bookmarkable blurbs on a page
    When the tag "Testing" is canonized
      And I go to the bookmarks tagged "Testing"
    # Open
    When I follow "Saved" in the bookmarkable blurb for "Bookmark: The Beginnings"
    Then the edit bookmark form should be open in the bookmarkable blurb for "Bookmark: The Beginnings"
    When I follow "Saved" in the bookmarkable blurb for "Bookmark: The Sequel"
    Then the edit bookmark form should be open in the bookmarkable blurb for "Bookmark: The Sequel"
    # Close
    When I exit the bookmark form for the bookmark of "Bookmark: The Beginnings"
    Then the edit bookmark form should be closed in the bookmarkable blurb for "Bookmark: The Beginnings"
    When I exit the bookmark form for the bookmark of "Bookmark: The Sequel"
    Then the edit bookmark form should be closed in the bookmarkable blurb for "Bookmark: The Sequel"
    # Reopen
    When I follow "Saved" in the bookmarkable blurb for "Bookmark: The Beginnings"
    Then the edit bookmark form should be open in the bookmarkable blurb for "Bookmark: The Beginnings"

  @javascript
  Scenario: The Save button correctly opens, closes, and reopens edit forms when there are multiple bookmarkable blurbs on a page
    When the tag "Testing" is canonized
      And I am logged out
      And I am logged in as "bookmarker"
      And I go to the bookmarks tagged "Testing"
    # Open
    When I follow "Save" in the bookmarkable blurb for "Bookmark: The Beginnings"
    Then the new bookmark form should be open in the bookmarkable blurb for "Bookmark: The Beginnings"
    When I follow "Save" in the bookmarkable blurb for "Bookmark: The Sequel"
    Then the new bookmark form should be open in the bookmarkable blurb for "Bookmark: The Sequel"
    # Close
    When I exit the bookmark form for the bookmark of "Bookmark: The Beginnings"
    Then the new bookmark form should be closed in the bookmarkable blurb for "Bookmark: The Beginnings"
    When I exit the bookmark form for the bookmark of "Bookmark: The Sequel"
    Then the new bookmark form should be closed in the bookmarkable blurb for "Bookmark: The Sequel"
    # Reopen
    When I follow "Save" in the bookmarkable blurb for "Bookmark: The Beginnings"
    Then the new bookmark form should be open in the bookmarkable blurb for "Bookmark: The Beginnings"
