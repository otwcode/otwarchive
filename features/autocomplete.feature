Feature: Display autocomplete for tags
  In order to facilitate posting
  As a registered user
  I should be getting autocompletes for my tags

Scenario: Autocomplete tags for new work
    Given the following activated user exists
      | login      | password   |
      | fandomer   | password   |
      And a fandom exists with name: "Supernatural", canonical: true
      And a fandom exists with name: "suppper", canonical: false
      And a character exists with name: "Ellen Harvelle", canonical: true
      And a character exists with name: "ellen tigh", canonical: false
      And a pairing exists with name: "Destiel", canonical: false
      And a pairing exists with name: "Dean/Castiel", canonical: true
      And a freeform exists with name: "Alternate Universe", canonical: true
      And a freeform exists with name: "alternate sundays", canonical: false
      And I am logged in as "fandomer" with password "password"
    When I go to the new work page
      And I fill in "Fandoms" with "Sup"
    Then I should find "Supernatural" within "div.auto_complete"
      But I should not find "suppper" within "div.auto_complete"
    When I fill in "Characters" with "ellen"
    Then I should find "Ellen Harvelle" within "div.auto_complete"
      But I should not find "ellen tigh" within "div.auto_complete"
    When I fill in "Pairings" with "stiel"
    Then I should not find "Destiel" within "div.auto_complete"
      But I should find "Dean/Castiel" within "div.auto_complete"
    When I fill in "Additional Tags" with "alt"
    Then I should find "Alternate Universe" within "div.auto_complete"
      But I should not find "alternate sundays" within "div.auto_complete"

Scenario: Autocomplete tags for user's tags on a bookmark
    Given I have loaded the fixtures
      And a character exists with name: "John Sheppard", canonical: true
      And a character exists with name: "Roddy", canonical: false
      And a pairing exists with name: "McShep", canonical: true
      And a pairing exists with name: "John/Rodney", canonical: false
      And a freeform exists with name: "Episode Duet", canonical: true
      And a freeform exists with name: "Duet ep tag", canonical: false
      And I am logged in as "testuser" with password "testuser" 
    When I view the work "First work"
      And I follow "Bookmark"
      And I fill in "Your Tags" with "fir"
    Then I should find "first fandom" within "div.auto_complete"
    When I fill in "Your Tags" with "She"
    Then I should find "John Sheppard" within "div.auto_complete"
      And I should find "McShep" within "div.auto_complete"
    When I fill in "Your Tags" with "Rod"
    Then I should not find "Roddy" within "div.auto_complete"
      And I should not find "John/Rodney" within "div.auto_complete"
    When I fill in "Your Tags" with "McS"
    Then I should find "McShep" within "div.auto_complete"
    When I fill in "Your Tags" with "Due"
    Then I should find "Episode Duet" within "div.auto_complete"
      But I should not find "Duet ep tag" within "div.auto_complete"
      
Scenario: Autocomplete tags for external works (author's tags)
    Given the following activated user exists
      | login      | password   |
      | fandomer   | password   |
      And I am logged in as "fandomer" with password "password"
      And a fandom exists with name: "Supernatural", canonical: true
      And a fandom exists with name: "suppper", canonical: false
      And a character exists with name: "Ellen Harvelle", canonical: true
      And a character exists with name: "ellen tigh", canonical: false
      And a pairing exists with name: "Destiel", canonical: false
      And a pairing exists with name: "Dean/Castiel", canonical: true
      And I go to the new external work page
      And I fill in "Fandoms" with "Sup"
    Then I should find "Supernatural" within "div.auto_complete"
      But I should not find "suppper" within "div.auto_complete"
    When I fill in "Characters" with "ellen"
    Then I should find "Ellen Harvelle" within "div.auto_complete"
      But I should not find "ellen tigh" within "div.auto_complete"
    When I fill in "Pairings" with "stiel"
    Then I should not find "Destiel" within "div.auto_complete"
      But I should find "Dean/Castiel" within "div.auto_complete"

Scenario: URL autocomplete for external works
    Given I have loaded the fixtures
      And I am logged in as "testuser" with password "testuser"
      And I go to the new external work page
      And I fill in "URL" with "http://z"
    Then I should find "zooey-glass.dreamwidth.org"
      But I should not find "parenthetical.livejournal.com"