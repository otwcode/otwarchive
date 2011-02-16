@users
Feature:
  In order to correct mistakes or reflect my evolving personality
  As a registered user
  I want to be able to delete my account

  Scenario: Delete a user with no works
    Given I am logged in
      And I have no works
    When I delete my account
    Then I cannot log in

  Scenario: Delete a user and delete works
    Given I am logged in
      And I have 1 work
    When I delete my account and delete my work
    Then I cannot log in
      And my work does not exist

  Scenario: Delete a user and orphan works
    Given I am logged in
      And I have 1 work
    When I delete my account and orphan my work
    Then I cannot log in
      And my work is orphaned

  Scenario: Delete a user and orphan collection
    Given I am logged in
      And I have 1 collection
    When I delete my account and orphan my collection
    Then I cannot log in
      And my collection is orphaned

