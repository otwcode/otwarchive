@bookmarks @javascript
Feature: Create, edit and delete bookmarks with javascript enabled
  In order to have a good user experience
  As a humble user
  I want to be able to create, edit and delete bookmarks with javascript enabled
  
  Background:
    Given I am logged in as "recengine"
      And I bookmark the work "Bookmark: The Beginnings"
      And I bookmark the work "Bookmark: The Sequel"
      And I bookmark the work "RedirectCorrectly"

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


  # Deleting redirects (AO3-4989)
  Scenario: Deleting bookmarks from your bookmarks page does not reset the filtering
    Given I am logged in as "PharloomEditor"
      And I post the work "Shakra"
      And I post the work "Hornet"
      And I post the work "Sherma"
      And I bookmark the work "Shakra" with the note "Silksong"
      And I bookmark the work "Hornet"
      And I bookmark the work "Sherma" with the note "Silksong"
    When I go to PharloomEditor's bookmarks page
      And I fill in "Search bookmarker's tags and notes" with "Silksong"
      And I press "Sort and Filter"
      And all indexing jobs have been run
      And I follow "Delete" in the bookmarkable blurb for "Shakra"
      And I confirm the bookmark's deletion
    Then I should not see "Shakra"
      And I should not see "Hornet"
      And I should see "Sherma"

  Scenario: Deleting bookmarks from your bookmarks page redirects you back
    When I go to recengine's bookmarks page
      And I follow "Delete" in the bookmarkable blurb for "RedirectCorrectly"
      And I confirm the bookmark's deletion
    Then I should be on recengine's bookmarks page

  Scenario: Deleting bookmarks from the bookmarks page redirects you back
    When I go to the bookmarks page
      And I follow "Delete" in the bookmarkable blurb for "RedirectCorrectly"
      And I confirm the bookmark's deletion
    Then I should be on the bookmarks page

  Scenario: Deleting bookmarks from a canonical tag's bookmarks page redirects you back
    Given I post the work "Hello" with freeform "Redirect"
      And the tag "Redirect" is canonized
      And I bookmark the work "Hello"
      And all indexing jobs have been run
      And I go to the bookmarks tagged "Redirect"
      And I follow "Delete" in the bookmarkable blurb for "Hello"
      And I confirm the bookmark's deletion
    Then I should be on the bookmarks tagged "Redirect"

  Scenario: Deleting bookmarks from a user pseud's bookmarks page redirects you back
    Given "recengine" has the pseud "alt"
      And I bookmark the work "Alternate" as "alt"
      And I go to the bookmarks page of "recengine" as pseud "alt"
      And I follow "Delete" in the bookmarkable blurb for "Alternate"
      And I confirm the bookmark's deletion
    Then I should be on the bookmarks page of "recengine" as pseud "alt"

  Scenario: Deleting bookmarks from a work's bookmarks page redirects you back
    Given I go to the bookmarks page for the work "RedirectCorrectly"
      And I follow "Delete"
      And I confirm the bookmark's deletion
    Then I should be on the bookmarks page for the work "RedirectCorrectly"

  Scenario: Deleting bookmarks from the bookmark's page redirects you to your user bookmarks page
    Given I bookmark the work "VeryShortLived"
      And I follow "Delete"
      And I confirm the bookmark's deletion
    Then I should be on recengine's bookmarks page

  Scenario: Deleting bookmarks from a non-canonical tag's page redirects you to your user bookmarks page
    Given I bookmark the work "Ruby" with the tags "Sapphire"
      And I go to the "Sapphire" tag page
      And I follow "Delete" in the bookmarkable blurb for "Ruby"
      And I confirm the bookmark's deletion
    Then I should be on recengine's bookmarks page
