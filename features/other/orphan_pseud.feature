@works
Feature: Orphan pseud
  In order to have an archive full of works
  As an author
  I want to orphan all works under one pseud
  # TODO: Expand this to cover a user who has more than one pseud, and check that works on the other pseud don't get orphaned

Scenario: Orphan all works belonging to one pseud
  Given I have an orphan account
  And the following activated user exists
    | login         | password   |
    | orphanpseud   | password   |
    And I am logged in as "orphanpseud" with password "password"
  When I post the work "Shenanigans"
    And I post the work "Shenanigans 2"
  When I follow "orphanpseud" within ".byline"
  Then I should see "Shenanigans 2 by orphanpseud"
  When I follow "Back To Pseuds"
  Then I should see "orphanpseud"
    And I should see "2 works"
  When I follow "Orphan Works"
  Then I should see "Orphan Works"
  When I choose "Take my pseud off as well"
    And I press "Yes, I'm sure"
  Then I should see "Orphaning was successful."
  When I view the work "Shenanigans"
  Then I should see "orphan_account"
    And I should not see "orphanpseud" within ".userstuff"
  When I view the work "Shenanigans 2"
  Then I should see "orphan_account"
    And I should not see "orphanpseud" within ".userstuff"

    Scenario: Orphan all works belonging to one pseud, add a copy of the pseud to the orphan_account
      Given I have an orphan account
      And the following activated user exists
        | login         | password   |
        | orphanpseud   | password   |
        And I am logged in as "orphanpseud" with password "password"
      When I post the work "Shenanigans"
      When I post the work "Shenanigans 2"
      When I follow "orphanpseud" within ".byline"
      Then I should see "Shenanigans by orphanpseud"
        And I should see "Shenanigans 2 by orphanpseud"
      When I follow "Back To Pseuds"
      Then I should see "orphanpseud"
        And I should see "2 works"
      When I follow "Orphan Works"
      Then I should see "Orphan Works"
      When I choose "Leave a copy of my pseud on"
        And I press "Yes, I'm sure"
      Then I should see "Orphaning was successful."
      When I view the work "Shenanigans"
      Then I should see "orphanpseud (orphan_account)"
        And I should not see "orphanpseud" within ".userstuff"
      When I view the work "Shenanigans 2"
      Then I should see "orphanpseud (orphan_account)"
        And I should not see "orphanpseud" within ".userstuff"
