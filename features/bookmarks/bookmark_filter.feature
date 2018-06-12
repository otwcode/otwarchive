@bookmarks
Feature: Filter bookmarks
  In order to search an archive full of bookmarks
  As a humble user
  I want to filter some bookmarks

  @new-search
  Scenario: Filter a user's bookmarks by work language
    Given I have loaded the fixtures
      And I am logged in as "recengine"
      And I bookmark the work "First work"
      And I bookmark the work "second work"
      And I bookmark the work "third work"
    When I go to my bookmarks page
      And I select "Deutsch" from "Work language"
      And I press "Sort and Filter"
    Then I should see "1 Bookmark by recengine"
      And I should not see "first work"
      And I should not see "second work"
      And I should see "third work"
