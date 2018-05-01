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
  Scenario: Synning a canonical tag used on bookmarked series and external works
  should move the bookmarks to the new canonical's bookmark listings; de-synning
  should remove them
    Given I am logged in as "author"
      And a canonical fandom "Veronica Mars"
      And a canonical fandom "Veronica Mars (TV)"
      And I post the work "The Story Telling: Beginnings" with fandom "Veronica Mars" as part of a series "Telling Stories"
      And I am logged in as "bookmarker"
      And I bookmark the series "Telling Stories"
      And I bookmark the external work "Outside Story" with fandom "Veronica Mars"
    When I go to the bookmarks tagged "Veronica Mars"
    Then I should see "Outside Story"
      And I should see "Telling Stories"
    When I am logged in as a tag wrangler
      And I syn the tag "Veronica Mars" to "Veronica Mars (TV)"
      And I go to the bookmarks tagged "Veronica Mars (TV)"
    Then I should see "Outside Story"
      And I should see "Telling Stories"
    When I de-syn the tag "Veronica Mars" from "Veronica Mars (TV)"
      And the tag "Veronica Mars" is canonized
      And I go to the bookmarks tagged "Veronica Mars (TV)"
    Then I should not see "Telling Stories"
      And I should not see "Outside Story"
    When I go to the bookmarks tagged "Veronica Mars"
    Then I should see "Outside Story"
      And I should see "Telling Stories"

  @new-search
  Scenario: Subtagging a tag used on bookmarked series and external works should
  make the bookmarks appear in the metatag's bookmark listings; de-subbing
  should remove them
    Given I am logged in as "author"
      And a canonical character "Laura"
      And a canonical character "Laura Roslin"
      And I post the work "The Story Telling: Beginnings" with character "Laura Roslin" as part of a series "Telling Stories"
      And I am logged in as "bookmarker"
      And I bookmark the series "Telling Stories"
      And I bookmark the external work "Outside Story" with character "Laura Roslin"
    When I go to the bookmarks tagged "Laura Roslin"
    Then I should see "Outside Story"
      And I should see "Telling Stories"
    When I am logged in as a tag wrangler
      And I subtag the tag "Laura Roslin" to "Laura"
      And I go to the bookmarks tagged "Laura"
    Then I should see "Outside Story"
      And I should see "Telling Stories"
    When I remove the metatag "Laura" from "Laura Roslin"
      And I go to the bookmarks tagged "Laura"
    Then I should not see "Telling Stories"
      And I should not see "Outside Story"
    When I go to the bookmarks tagged "Laura Roslin"
    Then I should see "Outside Story"
      And I should see "Telling Stories"
    When I go to the bookmarks tagged "Alternate Universe - High School"
    Then the 1st bookmark result should contain "Telling Stories"

  Scenario: Adding a chapter to a work in a series should update the series, as
  should deleting a chapter from a work in a series
    Given I am logged in as "creator"
      And I have bookmarks of old series to search
    When a chapter is added to "WIP in a Series"
      And I go to the search bookmarks page
      And I select "Series" from "Type"
      And I select "Date Updated" from "Sort by"
      And I press "Search bookmarks"
    Then the 1st bookmark result should contain "Older WIP Series"
      And the 2nd bookmark result should contain "Newer Complete Series"
    When I delete chapter 2 of "WIP in a Series"
      And I go to the search bookmarks page
      And I select "Series" from "Type"
      And I select "Date Updated" from "Sort by"
      And I press "Search bookmarks"
    Then the 1st bookmark result should contain "Newer Complete Series"
      And the 2nd bookmark result should contain "Older WIP Series"
