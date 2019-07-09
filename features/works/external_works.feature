@works

Feature: External works are not hosted on the Archive

  Scenario: Can see external works
    Given basic tags
      And I am logged in as "regular_user"
      And I bookmark the external work "External Changes"
      And I bookmark the external work "All changes"
      And I am logged in as "less_regular_user"
      And I bookmark the external work "External Changes"
    When I go to the external works page
    Then I should see "External Changes"
      And I should see "All changes"
      But I should not see "Show duplicates"
    When I go to the external works with only duplicates page
    Then I should see "External Changes"
      And I should not see "All changes"
    When I am logged in as an admin
      And I go to the external works page
    Then I should see "External Changes"
      And I should see "All changes"
      And I should see "Show duplicates (1)"
    When I follow "Show duplicates"
    Then I should see "External Changes"
      But I should not see "All changes"
