@collections
Feature: Collection
  In order to have an archive full of collections
  As a humble user
  I want to browse an existing collection

  Scenario: Filter collections index, first to prompt meme; then to gift exchange; then by adding moderated to the gift exchange filter; and then by either moderated or not, closed, and no challenge
  
  Given I have loaded the fixtures
    And I am logged in as "testuser" with password "testuser"
  When I go to the collections page
    And I choose "Prompt Meme Challenge"
    And I press "Filter"
  Then I should see "On Demand"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Test Collection"
    And I should not see "Another Plain Collection"
    And I should not see "Surprise Presents"
    And I should not see "Another Gift Swap"
  When I choose "Gift Exchange Challenge"
    And I press "Filter"
  Then I should see "Surprise Presents"
    And I should see "Another Gift Swap"
    And I should not see "On Demand"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Test Collection"
    And I should not see "Another Plain Collection"
  When I choose "collection_filters_moderated_true"
    And I choose "Gift Exchange Challenge"
    And I press "Filter"
  Then I should see "Surprise Presents"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Test Collection"
    And I should not see "Another Plain Collection"
  When I choose "collection_filters_moderated_"
    And I choose "No Challenge"
    And I choose "collection_filters_closed_true"
    And I press "Filter"
  Then I should see "Another Plain Collection"
    And I should not see "Some Test Collection"
    And I should not see "Some Other Test Collection"
    And I should not see "Surprise Presents"
    And I should not see "Another Gift Swap"
    And I should not see "On Demand"

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
