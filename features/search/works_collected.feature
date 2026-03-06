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
      And "Date Updated" should be selected within "Sort by"
      And "Revised Title" should appear before "New Title"
      And "New Title" should appear before "Old Title"
    When I select "Title" from "Sort by"
      And I press "Sort and Filter"
    Then "Title" should be selected within "Sort by"
      And "New Title" should appear before "Old Title"
      And "Old Title" should appear before "Revised Title"
    When I select "Date Posted" from "Sort by"
      And I press "Sort and Filter"
    Then "Date Posted" should be selected within "Sort by"
      And "New Title" should appear before "Revised Title"
      And "Revised Title" should appear before "Old Title"
    When I check "Author Collection"
      And I check "Other Collection"
      And I press "Sort and Filter"
    Then the "Author Collection" checkbox should be checked
      And the "Other Collection" checkbox should be checked
      And I should see "New Title"
      And I should see "Revised Title"
      And I should see "Old Title"
    When I uncheck "Other Collection"
      And I press "Sort and Filter"
    Then the "Author Collection" checkbox should be checked
      And I should not see "Other Collection"
      And I should not see "New Title"
      And I should see "Revised Title"
      And I should see "Old Title"

  Scenario: Works that are collected in an unrevealed or anonymous collection
  has correct blurbs in the creator's collected works page for admins and the
  creator, and the collections exist on filters on that page
    Given I have the anonymous collection "Johnlock"
    And I have the hidden collection "Adlock"
    And I am logged in as "author"
      And I post the work "Normal"
      And I post the work "Scarlet" in the collection "Johnlock"
      And I post the work "Hound" in the collection "Adlock"
    When I go to author's user page
      And I follow "Works (1)"
      And I follow "Works in Collections"
    Then I should see "Anonymous: Scarlet by Anonymous"
      And I should see "Unrevealed: Hound by author"
      And I should see "Johnlock (1)"
      And I should see "Adlock (1)"
    When I am logged in as an admin
      And I go to author's user page
      And I follow "Works (1)"
      And I follow "Works in Collections"
    Then I should see "Anonymous: Scarlet by Anonymous"
      And I should see "Unrevealed: Hound by author"
      And I should see "Johnlock (1)"
      And I should see "Adlock (1)"
    When I am logged in as a random user
      And I go to author's user page
      And I follow "Works (1)"
      And I follow "Works in Collections"
    Then I should not see "Anonymous: Scarlet by Anonymous"
      And I should not see "Unrevealed: Hound by author"
      And I should not see "Johnlock (1)"
      And I should not see "Adlock (1)"

