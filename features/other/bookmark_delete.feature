@bookmarks
Feature: Delete bookmarks
  In order to have an archive full of relevant bookmarks
  As a humble user
  I want to delete bookmarks I make in error or no longer care about
  
Scenario: Delete work, series, and external work bookmarks

    Given the following activated users exist
      | login           | password   |
      | wahlly   | password   |
      | markymark   | password   |
      And I am logged in as "wahlly"
      And I add the work "A Mighty Duck" to series "The Funky Bunch"
    When I log out
      And I am logged in as "markymark"
      And I view the work "A Mighty Duck"
      And I follow "Bookmark"
      And I press "Create"
    Then I should see "Bookmark was successfully created."
      And I should see "Delete"
    When I follow "Delete"
    Then I should see "Are you sure you want to delete"
      And I should see "A Mighty Duck"
    When I press "Yes, Delete Bookmark"
    Then I should see "Bookmark was successfully deleted."
      And I should see "Bookmarks by markymark"
      And I should not see "A Mighty Duck"
    When I view the series "The Funky Bunch"
      And I follow "Bookmark Series"
      And I press "Create"
    Then I should see "Bookmark was successfully created."
    When I follow "Delete"
    Then I should see "Are you sure you want to delete"
      And I should see "The Funky Bunch"
    When I press "Yes, Delete Bookmark"
    Then I should see "Bookmark was successfully deleted."
      And I should see "Bookmarks by markymark"
      And I should not see "The Funky Bunch"
      
@culerity
Scenario: Delete work, series, and external work bookmarks without JavaScript