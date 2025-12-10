@bookmarks
Feature: Edit bookmarks with javascript enabled
  In order to have a good user experience
  As a humble user
  I want to be able to edit bookmarks with javascript enabled
  
  Background:
    Given a canonical fandom "The Bookmarks"
      And the work "Bookmark: The Beginnings" by "bookmarker" with fandom "The Bookmarks"
      And the work "Bookmark: The Sequel" by "bookmarker" with fandom "The Bookmarks"
      And all indexing jobs have been run
      And the dashboard counts have expired
      And I am logged in as "bookmarker"

  @javascript
  Scenario: Opening multiple edit forms lets you close all of them (AO3-7214)
    Given I am logged in as "recengine"
      And I bookmark the work "Bookmark: The Beginnings"
      And I bookmark the work "Bookmark: The Sequel"
      And all indexing jobs have been run
    When I follow "Bookmarks"
      And I follow "Edit"
      And I follow "Edit"
    Then I should not see "Edit"
    When I exit the bookmark edit form
      And I exit the bookmark edit form
    Then I should not see "save a bookmark!"
  
  @javascript
  Scenario: The edit form can be reopened after closing it with "X" on some pages (AO3-7215)
    Given I am logged in as "recengine"
      And I bookmark the work "Bookmark: The Beginnings"
    When I view the work "Bookmark: The Beginnings"
      And I follow "1"
      And I follow "Edit"
    Then I should see "save a bookmark!"
      And I should not see "Edit Bookmark"
    When I exit the bookmark edit form
    Then I should see "Edit Bookmark"
    When I follow "Edit"
    Then I should see "save a bookmark!"

