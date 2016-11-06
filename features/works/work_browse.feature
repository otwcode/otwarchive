@works @browse
Feature: browsing works from various contexts

Scenario: browsing works with incorrect page params in query string

  Given I am logged in as a random user
    And a fandom exists with name: "Johnny Be Good", canonical: true
    And I post the work "Whatever" with fandom "Johnny Be Good"
  When I browse the "Johnny Be Good" works with an empty page parameter
  Then I should see "1 Work"

Scenario: browsing works and limiting to a fandom

  Given I am logged in as a random user
    And a fandom exists with name: "Johnny Be Good", canonical: true
    And a fandom exists with name: "Babylon 5", canonical: true
    And I post the work "Whatever" with fandom "Johnny Be Good, Babylon 5"
    And I post the work "Whichever" with fandom "Johnny Be Good"
  When I browse the "Johnny Be Good" works with fandom set to "Babylon 5"
  Then I should see "1 Work in Johnny Be Good in Babylon 5"
