@collections
Feature: Collection
  In order to have an archive full of collections
  As a humble user
  I want to create a collection and post to it

  Scenario: Create a collection

  Given the following activated user exists
    | login          | password    |
    | myname1        | something   |
    And a warning exists with name: "No Archive Warnings Apply", canonical: true
    And I am logged in as "myname1" with password "something"
  Then I should see "Hi, myname1!"
    And I should see "Log out"
  When I post the work "Test work thingy"
  Then I should see "Work was successfully posted."
  When I go to the collections page
  Then I should see "Collections in the Example Archive"
    And I should not see "My Collection Thing"
  When I follow "New Collection"
    And I fill in "Display Title" with "My Collection Thing"
    And I fill in "Collection Name" with "collection_thing"
    And I fill in "Introduction" with "Welcome to the collection"
    And I fill in "FAQ" with "<dl><dt>What is this thing?</dt><dd>It's a collection</dd></dl>"
    And I fill in "Rules" with "Be nice to people"
    And I press "Submit"
  Then I should see "Collection was successfully created"
  When I go to the collections page
  Then I should see "My Collection Thing"
  When I follow "My Collection Thing"
  Then I should see "Post To Collection"
  When I post the work "collect-y work"
    And I follow "myname1"
  Then I should see "collect-y work"
  When I edit the work "collect-y work"
    And I fill in "work_collection_names" with "collection_thing"
    And I press "Preview"
    And I press "Update"
  Then I should see "collect-y work"
    And I should see "Collections: My Collection Thing"
    
