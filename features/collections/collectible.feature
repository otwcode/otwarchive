@bookmarks @collections @works

Feature: Collectible items
  As a user
  I want to add my items to collections

  Scenario: Add my work to a collection
    Given I have a collection "Various Penguins"
      And I am logged in as a random user
      And I post the work "Blabla"
    When I add my work to the collection
    Then I should see "Added"
    When I go to "Various Penguins" collection's page
    Then I should see "Works (1)"
      And I should see "Blabla"

  Scenario: Add my chaptered work to a collection
    Given I have a collection "Various Penguins"
      And I am logged in as a random user
      And I post the chaptered work "Blabla"
    When I add my work to the collection
    Then I should see "Added"
    When I go to "Various Penguins" collection's page
    Then I should see "Works (1)"
      And I should see "Blabla"

  Scenario: Add my work to a moderated collection (Add to Collections button)
    Given I am logged in as "moderator" with password "password"
    Given I have a moderated collection "Various Penguins"
      And I am logged in as "Scott" with password "password"
      And I post the work "Blabla"
    When I add my work to the collection
    Then I should see "until it has been approved by a moderator."
    When I go to "Various Penguins" collection's page
    Then I should see "Works (0)"
      And I should not see "Blabla"

  Scenario: Add my work to a moderated collection (Edit work and add to collection)
    Given I have a moderated collection "Various Penguins"
      And I have a moderated collection "Various Aardvarks"
      And I am logged in as a random user
      And I post the work "Blabla"
      And I edit the work "Blabla"
      And I fill in "work_collection_names" with "various_penguins"
      And I press "Preview"
    Then I should see "the moderated collection 'Various Penguins'"
      And I press "Update"
      And I should see "the moderated collection 'Various Penguins'"
      And I fill in "collection_names" with "various_aardvarks"
      And I press "Add"
      And I follow "Edit"
      And I press "Post Without Preview"
      And I should see "moderated collections (Various Penguins, Various Aardvarks). It will not"

  Scenario: Add my work to both moderated and unmoderated collections
    Given I have a moderated collection "ModeratedCollection"
      And I have the collection "UnModeratedCollection"
      And I am logged in as a random user
      And I post the work "RandomWork"
      And I edit the work "RandomWork"
      And I fill in "work_collection_names" with "ModeratedCollection"
      And I press "Post Without Preview"
      And I go to "ModeratedCollection" collection's page
    Then I should not see "RandomWork"
      And I edit the work "RandomWork"
      And I fill in "work_collection_names" with "UnModeratedCollection"
      And I press "Post Without Preview"
    When I go to "UnModeratedCollection" collection's page
      And I should see "RandomWork"
      And I go to "ModeratedCollection" collection's page
    Then I should not see "RandomWork"

  Scenario: Add my work to a closed collection
    Given I have a closed collection "Various Penguins"
      And I am logged in as a random user
      And I post the work "Blabla"
    When I add my work to the collection
    Then I should see "is closed"
    When I go to "Various Penguins" collection's page
    Then I should see "Works (0)"
      And I should not see "Blabla"

  Scenario: Add my bookmark to a collection
    Given I have a collection "Various Penguins"
      And I am logged in as a random user
      And I have a bookmark for "Tundra penguins"
    When I add my bookmark to the collection "Various_Penguins"
    Then I should see "Added"
    # caching prevents the link from showing up immediately
    # When I follow "Various Penguins"
    When I go to "Various Penguins" collection's page
    Then I should see "Bookmarks (1)" within "#dashboard"
      And I should see "Tundra penguins"

  Scenario: Add my bookmark to a moderated collection
    Given I have a moderated collection "Various Penguins"
      And I am logged in as a random user
      And I have a bookmark for "Tundra penguins"
    When I add my bookmark to the collection "Various_Penguins"
    Then I should see "until it has been approved by a moderator."
    When I go to "Various Penguins" collection's page
    Then I should see "Bookmarks (0)"
      And I should not see "Tundra penguins"

  Scenario: Add my bookmark to a closed collection
    Given I have a closed collection "Various Penguins"
      And I am logged in as a random user
      And I have a bookmark for "Tundra penguins"
    When I add my bookmark to the collection "Various_Penguins"
    Then I should see "is closed"
    When I go to "Various Penguins" collection's page
    Then I should see "Bookmarks (0)"
      And I should not see "Tundra penguins"

  Scenario: Bookmarks of deleted items are included on the collection's Manage
  Items page
    Given I have a collection "Various Penguins"
      And I am logged in as a random user
      And I have a bookmark of a deleted work
      And I add my bookmark to the collection "Various_Penguins"
    When I am logged in as the owner of "Various Penguins"
      And I view the approved collection items page for "Various Penguins"
    Then I should see "Bookmark of deleted item"
      And I should see "This has been deleted, sorry!"

  Scenario: Bookmarks of deleted items are included on the user's Manage
  Collected Works page
    Given I have a collection "Various Penguins"
      And I am logged in as a random user
      And I have a bookmark of a deleted work
    When I add my bookmark to the collection "Various_Penguins"
    Then I should see "Added"
    When I go to my collection items page
      And I follow "Approved"
    Then I should see "Bookmark of deleted item"
      And I should see "This has been deleted, sorry!"

  Scenario: Bookmarks of deleted items are included on the collection's Awaiting
  Approval Manage Items page
    Given I have a moderated collection "Various Penguins"
      And I am logged in as a random user
      And I have a bookmark of a deleted work
      And I add my bookmark to the collection "Various_Penguins"
    When I am logged in as the owner of "Various Penguins"
      And I view the awaiting approval collection items page for "Various Penguins"
    Then I should see "Bookmark of deleted item"
      And I should see "This has been deleted, sorry!"

  Scenario: Deleted works are not included on the user's Manage Collected Works page
    Given I have a collection "Various Penguins"
      And I am logged in as a random user
      And I post the work "Emperor Penguins" to the collection "Various Penguins"
      And I delete the work "Emperor Penguins"
    When I go to my collection items page
      And I follow "Approved"
    Then I should not see "Emperor Penguins"

  Scenario: Deleted works are not included on the collection's Manage Items page
    Given I have a collection "Various Penguins"
      And I am logged in as a random user
      And I post the work "Emperor Penguins" to the collection "Various Penguins"
      And I delete the work "Emperor Penguins"
    When I am logged in as the owner of "Various Penguins"
      And I view the approved collection items page for "Various Penguins"
    Then I should not see "Emperor Penguins"

  Scenario: Drafts are included on the user's Manage Collected Works page
    Given I have a collection "Various Penguins"
      And I am logged in as a random user
      And the draft "Sweater Penguins" in the collection "Various Penguins"
    When I go to my collection items page
      And I follow "Approved"
    Then I should see "Sweater Penguins (Draft)"

  Scenario: Drafts are included on a collection's Manage Items page
    Given I have a collection "Various Penguins"
      And I am logged in as a random user
      And the draft "Sweater Penguins" in the collection "Various Penguins"
    When I am logged in as the owner of "Various Penguins"
      And I view the approved collection items page for "Various Penguins"
    Then I should see "Sweater Penguins (Draft)" 