@works
Feature: Orphan work
  In order to have an archive full of works
  As an author
  I want to orphan works

  Scenario: Orphan a single work, using the default orphan_account
    Given I have loaded the fixtures
      And I am logged in as "testuser" with password "testuser" 
    When I view the work "First work"
    Then I should see "Edit"
    When I follow "Edit"
    Then I should see "Edit Work"
      And I should see "Orphan Work"
    When I follow "Orphan Work"
    Then I should see "Read More About The Orphaning Process"
    When I choose "Use the default orphan pseud"
      And I press "Yes, I'm sure"
    Then I should see "Orphaning was successful."
    When I follow "Works"
    Then I should not see "First work"
    When I view the work "First work"
    Then I should see "orphan_account"
      And I should not see "Delete"

  Scenario: Orphan a single work and add a copy of the pseud to the orphan_account
    Given I have loaded the fixtures
      And I am logged in as "testuser" with password "testuser" 
    When I view the work "First work"
    Then I should see "Edit"
    When I follow "Edit" 
    Then I should see "Edit Work"
      And I should see "Orphan Work"
    When I follow "Orphan Work"
    Then I should see "Read More About The Orphaning Process"
    When I choose "Make a copy of my pseud under the orphan account"
    And I press "Yes, I'm sure"
    Then I should see "Orphaning was successful."
    When I follow "Works"
    Then I should not see "First work"
    When I view the work "First work"
    Then I should see "testuser (orphan_account)"
      And I should not see "Delete"