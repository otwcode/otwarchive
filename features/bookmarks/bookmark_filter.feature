@bookmarks
Feature: Filter bookmarks
  In order to search an archive full of bookmarks
  As a humble user
  I want to filter some bookmarks

  Scenario: Filter a user's bookmarks by work language
    Given "recengine" has bookmarks of works in various languages
      And I am logged in as "recengine"
    When I go to my bookmarks page
      And I select "Deutsch" from "Work language"
      And I press "Sort and Filter"
    Then I should see "1 Bookmark by recengine"
      And I should not see "english work"
      And I should see "german work"
