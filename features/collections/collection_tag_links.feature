@tags @collections @works

Feature: Tag links do not include collection
  As a user
  I want to browse tags from anywhere without getting stuck in a collection

  Scenario: Browse a tag from a work in a collection
    Given I have a collection "Randomness"
      And a canonical fandom "Naruto"
      And I post the work "Has some tags" in the collection "Randomness"

    # check tag links from the work blurb in a collection
    When I go to "Randomness" collection's page
      And I follow "Naruto"
    Then I should be on the works tagged "Naruto"

    # check tag links from the work meta in a collection
    When I go to "Randomness" collection's page
      And I follow "Has some tags"
      And I follow "Naruto"
    Then I should be on the works tagged "Naruto"
