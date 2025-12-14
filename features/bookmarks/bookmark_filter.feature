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

  Scenario: Filtering series bookmarks by word count with restricted works
    Given a bookmark by "awesome_posterrr" of a mixed visibility series with fandom "What a fandom"
    # Logged-in behavior
    When I am logged in as "awesome_posterr"
      And I go to awesome_posterrr's bookmarks page
    # Verify the starting visible word count
    Then I should see "1 Bookmark by awesome_posterrr"
      And I should see "Words: 16"
    When I fill in "To" with "10" within "#work_words"
      And I press "Sort and Filter"
    Then I should see "0 Bookmarks by awesome_posterrr"
      And I should not see "Mixed Visibility"
    When I fill in "To" with "20" within "#work_words"
      And I fill in "From" with "5" within "#work_words"
      And I press "Sort and Filter"
    Then I should see "1 Bookmark by awesome_posterrr"
      And I should see "Mixed Visibility"
    # Logged out behavior
    When I am logged out
      And I go to awesome_posterrr's bookmarks page
    Then I should see "1 Bookmark by awesome_posterrr"
      And I should see "Words: 8"
    When I fill in "To" with "10" within "#work_words"
      And I press "Sort and Filter"
    Then I should see "1 Bookmark by awesome_posterrr"
      And I should see "Mixed Visibility"
    When I fill in "To" with "4" within "#work_words"
      And I press "Sort and Filter"
    Then I should see "0 Bookmarks by awesome_posterrr"

  Scenario: Sorting series bookmarks by word count with restricted works
    Given I am logged in as "poster_child"
      And I post the 2 chapter work "In between"
      And I post the 1 chapter work "Public" as part of a series "Mixed Visibility"
      And I post the 3 chapter work "Restricted" as part of a series "Mixed Visibility"
      And I lock the work "Restricted"
      And I bookmark the series "Mixed Visibility"
      And I bookmark the work "In between"
    When I go to poster_child's bookmarks page
      And I select "Word Count" from "Sort by"
      And I press "Sort and Filter"
    Then the 1st bookmark result should contain "Mixed Visibility"
      And the 1st bookmark result should contain "Words: 18"
      And the 2nd bookmark result should contain "In between"
      And the 2nd bookmark result should contain "Words: 9"
    When I am logged out
      And I go to poster_child's bookmarks page
      And I select "Word Count" from "Sort by"
      And I press "Sort and Filter"
    Then the 1st bookmark result should contain "In between"
      And the 1st bookmark result should contain "Words: 9"
      And the 2nd bookmark result should contain "Mixed Visibility"
      And the 2nd bookmark result should contain "Words: 6"
