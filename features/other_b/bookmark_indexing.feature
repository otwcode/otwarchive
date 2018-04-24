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
  Scenario: Synning a canonical tag used on a bookmarked series should move the 
  bookmark to the new canonical's bookmark listings; de-synning should remove it
    Given I am logged in as "author"
      And a canonical fandom "Veronica Mars"
      And a canonical fandom "Veronica Mars (TV)"
      And I post the work "The Story Telling: Beginnings" with fandom "Veronica Mars" as part of a series "Telling Stories"
      And I am logged in as "bookmarker"
      And I bookmark the series "Telling Stories"
    When I go to the bookmarks tagged "Veronica Mars"
    Then the 1st bookmark result should contain "Telling Stories"
    When I am logged in as a tag wrangler
      And I syn the tag "Veronica Mars" to "Veronica Mars (TV)"
      And I go to the bookmarks tagged "Veronica Mars (TV)"
    Then the 1st bookmark result should contain "Telling Stories"
    When I de-syn the tag "Veronica Mars" from "Veronica Mars (TV)"
      And the tag "Veronica Mars" is canonized
      And I go to the bookmarks tagged "Veronica Mars (TV)"
    Then I should not see "Telling Stories"
    When I go to the bookmarks tagged "Veronica Mars"
    Then the 1st bookmark result should contain "Telling Stories"
