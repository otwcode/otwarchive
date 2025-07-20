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

  Scenario: When logged out, the "save" button on bookmarks does not show
    Given I am logged in as "bookmarker"
      And I bookmark the work "Test" with the tags "testing"
    When I log out
      And I go to the bookmarks page for the tag "testing"
    Then I should see "Test"
      And I should not see a link "Save"
