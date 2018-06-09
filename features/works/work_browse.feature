@works @browse
Feature: Browsing works from various contexts

Scenario: Browsing works with incorrect page params in query string
  Given a canonical fandom "Johnny Be Good"
    And I am logged in
    And I post the work "Whatever" with fandom "Johnny Be Good"
  When I browse the "Johnny Be Good" works with page parameter ""
  Then I should see "1 Work"

@new-search
Scenario: If works in a listing exceed the maximum search result count,
  display a notice on the last page of results

  Given a canonical fandom "Aggressive Retsuko"
    And the max search result count is 4
    And 2 items are displayed per page
    And I am logged in
    And I post the work "Whatever 1" with fandom "Aggressive Retsuko"
    And I post the work "Whatever 2" with fandom "Aggressive Retsuko"
    And I post the work "Whatever 3" with fandom "Aggressive Retsuko"
    And I post the work "Whatever 4" with fandom "Aggressive Retsuko"

  When I browse the "Aggressive Retsuko" works with page parameter "2"
  Then I should see "3 - 4 of 4 Works"
    And I should not see "Please use the filters"

  When I post the work "Whatever 5" with fandom "Aggressive Retsuko"
    And I browse the "Aggressive Retsuko" works
  Then I should see "1 - 2 of 5 Works"
    And I should not see "Please use the filters"
  When I follow "Next"
  Then I should see "3 - 4 of 5 Works"
    And I should see "Displaying 4 results out of 5. Please use the filters"

  When I browse the "Aggressive Retsuko" works with page parameter "3"
  Then I should see "3 - 4 of 5 Works"
    And I should see "Displaying 4 results out of 5. Please use the filters"
  When I follow "Previous"
  Then I should see "1 - 2 of 5 Works"
    And I should not see "Please use the filters"
