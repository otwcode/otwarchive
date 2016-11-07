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

Scenario: Browsing a users works in a collection

  Given I am logged in as "james"
    And the following typed tags exists
    | name              | type         | canonical |
    | Cowboy Bebop      | Fandom       | true      |
    | Faye Valentine    | Character    | true      |
    | Ed                | Character    | true      |
  When I create the collection "Ride him cowboy" with name "bebop"
    And I post the work "Honky Tonk Women" with fandom "Cowboy Bebop" with character "Faye Valentine" with second character "Ed" to the collection "Ride him cowboy"
    And I post the work "Asteroid Blues" with fandom "Cowboy Bebop" with character "Faye Valentine"
    And I have test caching turned on
    And all search indexes are updated
  When I am logged in as a random user
    And I am on james's works page
  When I follow "Works in Collections"
  Then I should see "Honky Tonk Women"
    And I should not see "Asteroid Blues"

