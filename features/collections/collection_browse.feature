@collections
Feature: Collection
  In order to have an archive full of collections
  As a humble user
  I want to locate and browse an existing collection
  
  Scenario: Collections index should have different links for logged in and logged out users
  
  Given I am logged in as "onlooker"
  When I go to the collections page
  Then I should see "Open Challenges"
    And I should see "New Collection"
  When I log out
    And I go to the collections page
  Then I should see "Open Challenges"
    And I should not see "New Collection"

  Scenario: Filter collections index to only show prompt memes
  
  Given I have loaded the fixtures
  When I go to the collections page
    And I choose "Prompt Meme Challenge"
    And I press "Sort and Filter"
  Then I should see "On Demand"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"
    And I should not see "Surprise Presents"
    And I should not see "Another Gift Swap"
    
  Scenario: Filter collections index to only show gift exchanges
  
  Given I have loaded the fixtures
  When I go to the collections page
    And I choose "Gift Exchange Challenge"
    And I press "Sort and Filter"
  Then I should see "Surprise Presents"
    And I should see "Another Gift Swap"
    And I should not see "On Demand"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"
    
  Scenario: Filter collections index to only show non-challenge collections
  
  Given I have loaded the fixtures
  When I go to the collections page
    And I choose "No Challenge"
    And I press "Sort and Filter"
  Then I should see "Some Test Collection"
    And I should see "Some Other Collection"
    And I should see "Another Plain Collection"
    And I should not see "Surprise Presents"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"
  
  Scenario: Filter collections index to only show closed collections
  
  Given I have loaded the fixtures
  When I go to the collections page
    And I choose "collection_filters_closed_true"
    And I press "Sort and Filter"
  Then I should see "Another Plain Collection"
    And I should see "On Demand"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Surprise Presents"
    And I should not see "Another Gift Swap"
  
  Scenario: Filter collections index to only show open collections
    
  Given I have loaded the fixtures
  When I go to the collections page
    And I choose "collection_filters_closed_false"
    And I press "Sort and Filter"
  Then I should see "Some Test Collection"
    And I should see "Some Other Collection"
    And I should see "Surprise Presents"
    And I should see "Another Gift Swap"
    And I should not see "Another Plain Collection"
    And I should not see "On Demand"

  Scenario: Filter collections index to only show moderated collections

  Given I have loaded the fixtures
  When I go to the collections page
    And I choose "collection_filters_moderated_true"
    And I press "Sort and Filter"
  Then I should see "Surprise Presents"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"
    
  Scenario: Filter collections index to only show unmoderated collections
  
  Given I have loaded the fixtures
  When I go to the collections page
    And I choose "collection_filters_moderated_false"
    And I press "Sort and Filter"
  Then I should see "Some Test Collection"
    And I should see "Some Other Collection"
    And I should see "Another Plain Collection"
    And I should see "Another Gift Swap"
    And I should see "On Demand"
    And I should not see "Surprise Presents"
    
  Scenario: Filter collections index to show open, moderated gift exchanges
  
  Given I have loaded the fixtures
  When I go to the collections page
    And I choose "collection_filters_closed_false"
    And I choose "collection_filters_moderated_true"
    And I choose "Gift Exchange Challenge"
    And I press "Sort and Filter"
  Then I should see "Surprise Presents"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Collection"
    And I should not see "Another Plain Collection"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"

  Scenario: browse the collection filtered by a tag

  Given I have loaded the fixtures
    And the following typed tags exists
      | name              | type         | canonical |
      | Cowboy Bebop      | Fandom       | true      |
      | Faye Valentine    | Character    | true      |
      | Ed                | Character    | true      |
    And I am logged in as a random user
  When I create the collection "Ride him cowboy" with name "bebop"
    And I post the work "Honky Tonk Women" with fandom "Cowboy Bebop" with character "Faye Valentine" with second character "Ed" to the collection "Ride him cowboy"
    And I post the work "Asteroid Blues" with fandom "Cowboy Bebop" with character "Faye Valentine" to the collection "Ride him cowboy"
    And I have test caching turned on
  When I view the collection "Ride him cowboy"
    And I follow "Works (2)"
    And I follow "Faye Valentine"
  Then I should see "2 Works in Ride him cowboy"
  When I view the collection "Ride him cowboy"
    And I follow "Works (2)"
    And I follow "Ed"
  Then I should see "1 Work in Ride him cowboy"
  Then I have test caching turned off

  Scenario: Look at a collection, see the rules and intro and FAQ

  Given I have loaded the fixtures
    And I am logged in as "testuser" with password "testuser"
  When I go to the collections page
  Then I should see "Collections in the "
    And I should see "Some Test Collection"
  When I follow "Some Test Collection"
  Then I should see "Some Test Collection"
    And I should see "There are no works or bookmarks in this collection yet."
  When I follow "Profile"
  Then I should see "Welcome to the test collection" within "#intro"
    And I should see "What is this test thing?" within "#faq"
    And I should see "It's a test collection" within "#faq"
    And I should see "Be nice to testers" within "#rules"
    And I should see "About Some Test Collection (sometest)"
