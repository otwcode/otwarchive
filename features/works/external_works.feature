@works

Feature: External works are not hosted on the Archive

  Scenario: Can see an external works
    Given basic tags
      And I am logged in as "regular_user"
      And I bookmark the external work "External Changes"
      And I am logged in as "less_regular_user"
      And I bookmark the external work "External Changes"
    When I go to the external works page
    Then "External Changes" should appear before "External Changes"
    When I go to the external works without duplicates page
    Then "External Changes" should not appear before "External Changes"


