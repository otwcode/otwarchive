Feature: Bookmarks as collectible items
  As a bookmarker
  I want to add bookmarks to collections
  So I can make thematic recs or whatnot
  
  Scenario: Add my bookmark to a collection
    Given I have a collection "Various Penguins"
      And I am logged in as a random user
      And I have a bookmark for "Tundra penguins"
    When I add my bookmark to the collection
    Then show me the main content
    Then I should see "Added"
    # TODO: add something to bookmark blurb about collection belonging, similar to works?
#      And I follow "Various Penguins"
    When I go to "Various Penguins" collection's page
    Then I should see "Bookmarks (1)"
    
  Scenario: Add my work to a collection
    Given I have a collection "Various Penguins"
      And I am logged in as a random user
      And I post the work "Blabla"
    When I add my work to the collection
    Then show me the main content
    Then I should see "Added"
    When I go to "Various Penguins" collection's page
    Then I should see "Works (1)"
