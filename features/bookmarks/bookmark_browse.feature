@bookmarks @search
Feature: Browse Bookmarks

  Scenario: Bookmarks appear on both the user's bookmark page and on the bookmark page for the pseud they used create the bookmark

    Given I am logged in as "ethel"
      And "ethel" creates the pseud "aka"
      And I bookmark the work "Bookmarked with Default Pseud"
      And I bookmark the work "Bookmarked with Other Pseud" as "aka"
    When I go to ethel's bookmarks page
    Then I should see "Bookmarked with Default Pseud"
      And I should see "Bookmarked with Other Pseud"
    When I go to the bookmarks page for user "ethel" with pseud "ethel"
    Then I should see "Bookmarked with Default Pseud"
      And I should not see "Bookmarked with Other Pseud"
    When I go to the bookmarks page for user "ethel" with pseud "aka"
    Then I should see "Bookmarked with Other Pseud"
      And I should not see "Bookmarked with Default Pseud"

  Scenario: Bookmark blurb includes an HTML comment containing the unix epoch of the updated time
    Given time is frozen at 2025-04-12 17:00 UTC
      And I am logged in as "ethel"
      And I bookmark the work "Test"
    When I go to ethel's bookmarks page
    Then I should see an HTML comment containing the number 1744477200 within "li.bookmark.blurb"

  Scenario: Bookmarked series' blurbs do not show tags on restricted works
    Given I am logged in as "bookmarker"
      And I post the work "Public Work" with fandom "FandomP" with character "Foobar" as part of a series "Mixed Access"
      And I post the work "Restricted Work" with fandom "FandomR" with character "Foobar" as part of a series "Mixed Access"
      And I lock the work "Restricted Work"
      And I bookmark the series "Mixed Access"
    When I go to the first bookmark for the series "Mixed Access"
    Then I should see "FandomP"
      And I should see "Foobar"
      But I should not see "FandomR"
    When I am logged out
      And I go to the first bookmark for the series "Mixed Access"
    Then I should see "FandomP"
      And I should see "Foobar"
      But I should not see "FandomR"
