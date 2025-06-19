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

  Scenario: Bookmarked series' blurbs show tags on restricted works only to logged in users
    Given I am logged in as "bookmarker"
      And I post the work "Public Work" with fandom "FandomP" with character "Foobar" as part of a series "Mixed Access"
      And I post the work "Restricted Work" with fandom "FandomR" with character "Foobar" as part of a series "Mixed Access"
      And I lock the work "Restricted Work"
      And I bookmark the series "Mixed Access"
    When I go to the first bookmark for the series "Mixed Access"
    Then I should see "FandomP"
      And I should see "FandomR"
      And I should see "Foobar"
    When I am logged out
      And I go to the first bookmark for the series "Mixed Access"
    Then I should see "FandomP"
      And I should see "Foobar"
      But I should not see "FandomR"
