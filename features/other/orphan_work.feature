@works
Feature: Orphan work
  In order to have an archive full of works
  As an author
  I want to orphan works

  Scenario: Orphan a single work, using the default orphan_account
    Given I have an orphan account
    And the following activated user exists
      | login         | password   |
      | orphaneer     | password   |
      And I am logged in as "orphaneer" with password "password"
      And I post the work "Shenanigans"
    When I view the work "Shenanigans"
    Then I should see "Edit"
    When I follow "Edit"
    Then I should see "Edit Work"
      And I should see "Orphan Work"
    When I follow "Orphan Work"
    Then I should see "Read More About The Orphaning Process"
    When I choose "Take my pseud off as well"
      And I press "Yes, I'm sure"
    Then I should see "Orphaning was successful."
    When all search indexes are updated
      And I follow "Bookmarks (0)"
      And I follow "Works (0)"
    Then I should not see "Shenanigans"
    When I view the work "Shenanigans"
    Then I should see "orphan_account"
      And I should not see "Delete"
  # Orphan a single work and add a copy of the pseud to the orphan_account
    When I post the work "Shenanigans2"
    When I view the work "Shenanigans2"
    Then I should see "Edit"
    When I follow "Edit"
    Then I should see "Edit Work"
      And I should see "Orphan Work"
    When I follow "Orphan Work"
    Then I should see "Read More About The Orphaning Process"
    When I choose "Leave a copy of my pseud on"
    And I press "Yes, I'm sure"
    Then I should see "Orphaning was successful."
    When I am on my works page
    Then I should not see "Shenanigans2"
    When I view the work "Shenanigans2"
    Then I should see "orphaneer (orphan_account)"
      And I should not see "Delete"
