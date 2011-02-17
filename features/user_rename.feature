@users
Feature:
  In order to correct mistakes or reflect my evolving personality
  As a registered user
  I want to be able to change my user name

  Scenario: I need to enter my password to change my username
    Given I am logged in with username "unchanged"
    When I change my username to "changed" using password "wrongpassword"
    Then I should not have username "changed"

  Scenario: Change my user name
    Given I am logged in with username "unchanged"
    When I change my username to "changed"
    Then I should have username "changed"

  Scenario: Change my user name to a taken username
    Given A user "changed" exists
      And I am logged in with username "unchanged"
    When I change my username to "changed"
    Then I should not have username "changed"

  Scenario: Change the capitalization of my username
    Given I am logged in with username "unchanged"
    When I change my username to "Unchanged"
    Then I should have username "Unchanged"

  Scenario: Changing my username changes my default pseud
   Given I am logged in with username "unchanged"
   When I change my username to "changed"
   Then I should have a default pseud of "changed"

  Scenario: Changing my username to one of my pseud's does not change my pseuds
   Given I am logged in with username "unchanged"
     And I have pseud "changed"
   When I change my username to "changed"
   Then I should have pseud "unchanged"
     And I should have pseud "changed"

