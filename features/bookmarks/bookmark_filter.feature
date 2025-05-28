@bookmarks
Feature: Filter bookmarks
  In order to search an archive full of bookmarks
  As a humble user
  I want to filter some bookmarks

  Scenario: Filter a user's bookmarks by work language
    Given "recengine" has bookmarks of works in various languages
      And I am logged in as "recengine"
    When I go to recengine's bookmarks page
      And I select "Deutsch" from "Work language"
      And I press "Sort and Filter"
    Then I should see "1 Bookmark by recengine"
      And I should not see "english work"
      And I should see "german work"
    When I follow "Clear Filters"
    Then I should see "2 Bookmarks by recengine"
      And I should see "english work"
      And I should see "german work"

  Scenario: Filtering series bookmarks by tags on restricted works
    Given I am logged in as "poster"
      And I post the work "Public" with fandom "PublicF" as part of a series "Mixed Visibility"
      And I post the work "Restricted" with fandom "RestrictedF" as part of a series "Mixed Visibility"
      And I lock the work "Restricted"
      And I bookmark the series "Mixed Visibility"
    When I go to the bookmarks tagged "RestrictedF"
    Then I should see "Mixed Visibility"
    When I go to the bookmarks tagged "PublicF"
    Then I should see "Mixed Visibility"
    When I am logged out
      And I go to the bookmarks tagged "RestrictedF"
    Then I should not see "Mixed Visibility"
    When I go to the bookmarks tagged "PublicF"
    Then I should see "Mixed Visibility"
