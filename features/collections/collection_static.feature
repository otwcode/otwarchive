@collections
Feature: Basic collection navigation

  Scenario: Create a collection and check the links
  Given basic tags
    And I have a canonical "TV Shows" fandom tag named "New Fandom"
    And a freeform exists with name: "Free", canonical: true
    And I have a collection "My Collection" with name "my_collection"
  When I go to "My Collection" collection's static page
  Then I should see "All Fandoms"
