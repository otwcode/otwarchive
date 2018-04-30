@bookmarks @search
Feature: Bookmark Indexing

  Scenario: Adding a new, out-of-fandom work to a series
    Given I am logged in as "author"
      And a canonical fandom "Veronica Mars"
      And a canonical fandom "X-Files"
      And I post the work "The Story Telling: Beginnings" with fandom "Veronica Mars" as part of a series "Telling Stories"
      And I post the work "Unrelated Story" with fandom "X-Files"
      And I am logged in as "bookmarker"
      And I bookmark the work "Unrelated Story"
      And I bookmark the series "Telling Stories"
    When I go to the bookmarks tagged "X-Files"
      And I select "Date Updated" from "Sort by"
      And I press "Sort and Filter"
    Then the 1st bookmark result should contain "Unrelated Story"
    When I am logged in as "author"
      And I post the work "The Story Returns" with fandom "X-Files" as part of a series "Telling Stories"
      And I go to the bookmarks tagged "X-Files"
    Then I should see "Telling Stories"
      And I should not see "This tag has not been marked common and can't be filtered on (yet)."
    When I select "Date Updated" from "Sort by"
      And I press "Sort and Filter"
    Then the 1st bookmark result should contain "Telling Stories"
      And the 2nd bookmark result should contain "Unrelated Story"
    When I go to bookmarker's user page
      And I follow "Bookmarks (2)"
      And I select "Date Updated" from "Sort by"
      And I press "Sort and Filter"
    Then the 1st bookmark result should contain "Telling Stories"
      And the 2nd bookmark result should contain "Unrelated Story"
    When author can use the new search
      And I go to the bookmarks tagged "X-Files"
    Then I should see "Telling Stories"
      And I should not see "This tag has not been marked common and can't be filtered on (yet)."
    When I select "Date Updated" from "Sort by"
      And I press "Sort and Filter"
    Then the 1st bookmark result should contain "Telling Stories"
      And the 2nd bookmark result should contain "Unrelated Story"

  @new-search
  Scenario: When a work in a series is updated with a new tag, bookmarks of the
  series should appear on the tag's bookmark listing; when a tag is removed, the
  bookmarks should disappear from the tag listing
    Given a canonical freeform "New Tag"
      And I am logged in
      And I post the work "Work" as part of a series "Series"
      And I bookmark the series "Series"
    When I edit the work "Work"
      And I fill in "Additional Tags" with "New Tag"
      And I press "Post Without Preview"
      And all indexing jobs have been run
      And I go to the bookmarks tagged "New Tag"
    Then the 1st bookmark result should contain "Series"
    When I edit the work "Work"
      And I fill in "Additional Tags" with ""
      And I press "Post Without Preview"
      And all indexing jobs have been run
      And I go to the bookmarks tagged "New Tag"
    Then I should not see "Series"
