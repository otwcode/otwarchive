@users
Feature: User dashboard
  In order to know what I've posted
  As a user
  I want to see summary information about my works on my dashboard

  Background:  Set up some tag relationships that appear on the dashboard
    Given the following fandom tags exist
      | name               | canonical |
      | Stargate SG-1      | true      |
      | Stargatte SG-oops  | false     |
      | Stargate Franchise | true      |
      And tag "Stargate SG-1" has metatag "Stargate Franchise"
      And tag "Stargate SG-1" has synonym "Stargatte SG-oops"

  Scenario: A user with no works
      Given I am logged in
        And I have no works
      When I visit my dashboard
      Then I should not see any fandoms or works

  Scenario: A user with one work should see their work and fandom
    Given I am logged in
      And I have a work with the following chararistics
        | Title  | My Test Work  |
        | Fandom | Stargate SG-1 |
    When I visit my dashboard
    Then I should see my work "My Test Work"
      And I should see the fandom "Stargate SG-1"
      And I should not see the fandom "Stargate Franchise"

  Scenario: A user with one work should see their work with the canonical fandom
    Given I am logged in
      And I have a work with the following chararistics
        | Title  | My Test Work      |
        | Fandom | Stargatte SG-oops |
    When I visit my dashboard
    Then I should see my work "My Test Work" with fandom "Stargatte SG-oops"
      And I should see the fandom "Stargate SG-1"
      And I should not see the fandom "Stargate Franchise"

