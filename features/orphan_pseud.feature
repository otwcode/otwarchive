@works
Feature: Orphan pseud
  In order to have an archive full of works
  As an author
  I want to orphan all works under one pseud

Scenario: Orphan all works belonging to one pseud
  Given the following activated user exists
    | login         | password   |
    | orphanpseud   | password   |
    And I am logged in as "orphanpseud" with password "password"
  When I post the work "Shenanigans"
    And I post the work "Shenanigans 2"
  When I follow "orphanpseud"
  Then I should see "Shenanigans 2 by orphanpseud"
  When I follow "My Pseuds"
  Then I should see "orphanpseud"
    And I should see "2 works"
  When I follow "Orphan Works"
  Then I should see "Orphan All Works by orphanpseud"
  When I choose "Use the default orphan pseud"
    And I press "Yes, I'm sure"
  Then I should see "Orphaning was successful."
  When I view the work "Shenanigans"
  Then I should see "orphan_account"
    And I should not see "orphanpseud" within ".user-generated-view"
  When I view the work "Shenanigans 2"
  Then I should see "orphan_account"
    And I should not see "orphanpseud" within ".user-generated-view"

    Scenario: Orphan all works belonging to one pseud, add a copy of the pseud to the orphan_account
      Given the following activated user exists
        | login         | password   |
        | orphanpseud   | password   |
        And I am logged in as "orphanpseud" with password "password"
      When I post the work "Shenanigans"
      When I post the work "Shenanigans 2"
      When I follow "orphanpseud"
      Then I should see "Shenanigans by orphanpseud"
        And I should see "Shenanigans 2 by orphanpseud"
      When I follow "My Pseuds"
      Then I should see "orphanpseud"
        And I should see "2 works"
      When I follow "Orphan Works"
      Then I should see "Orphan All Works by orphanpseud"
      When I choose "Make a copy of my pseud under the orphan account"
        And I press "Yes, I'm sure"
      Then I should see "Orphaning was successful."
      When I view the work "Shenanigans"
      Then I should see "orphanpseud (orphan_account)"
        And I should not see "orphanpseud" within ".user-generated-view"
      When I view the work "Shenanigans 2"
      Then I should see "orphanpseud (orphan_account)"
        And I should not see "orphanpseud" within ".user-generated-view"
