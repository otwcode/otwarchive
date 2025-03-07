Feature: Search collected works
  As a creator of collected works
  I want to filter for works across all those collections

  Scenario: Works that are collected show up in the creator's
  collected works page
    Given I am logged in as "author"
      And I create the collection "Author Collection"
      And I create the collection "Other Collection"
      And I post the work "Old Title" to the collection "Author Collection"
      And I wait 1 second
      And I post the work "Revised Title" to the collection "Author Collection"
      And I wait 1 second
      And I post the work "New Title" to the collection "Other Collection"
      And I wait 1 second
      And I post a chapter for the work "Revised Title"
    When I go to author's user page
      And I follow "Works (3)"
      And I follow "Works in Collections"
    Then I should see "Works in Challenges/Collections"
      And "Revised Title" should appear before "New Title"
      And "New Title" should appear before "Old Title"
    When I select "Title" from "Sort by"
      And I press "Sort and Filter"
    Then I should see "Works in Challenges/Collections"
      And "New Title" should appear before "Old Title"
      And "Old Title" should appear before "Revised Title"
