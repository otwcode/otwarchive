@collections
Feature: Collection
  In order to have an archive full of collections
  As a humble user
  I want to create a collection and post to it

  Scenario: Create a collection, post a work to it

  Given the following activated users exist
    | login          | password    |
    | myname1        | something   |
    | myname2        | something   |
    And I am logged in as "myname1" with password "something"
  When I post the work "Test work thingy"
  When I go to the collections page
  Then I should see "Collections in the "
    And I should not see "My Collection Thing"
  When I follow "New Collection"
    And I fill in "Display Title" with "My Collection Thing"
    And I fill in "Collection Name" with "collection_thing"
    And I fill in "Introduction" with "Welcome to the collection"
    And I fill in "FAQ" with "<dl><dt>What is this thing?</dt><dd>It's a collection</dd></dl>"
    And I fill in "Rules" with "Be nice to people"
    And I press "Submit"
  Then I should see "Collection was successfully created"
  When I follow "Profile"
  Then I should see "Welcome to the collection" within "#intro"
    And I should see "What is this thing?" within "#faq"
    And I should see "It's a collection" within "#faq"
    And I should see "Be nice to people" within "#rules"
  When I post the work "collect-y work"
    And I follow "myname1"
  Then I should see "collect-y work"
  When I edit the work "collect-y work"
    And I fill in "work_collection_names" with "collection_thing"
    And I press "Preview"
    And I press "Update"
  Then I should see "collect-y work"
    And I should see "Collections: My Collection Thing"

  When I follow "Log out"
    And I am logged in as "myname2" with password "something"
  When I go to the collections page
  Then I should see "My Collection Thing"
  When I follow "My Collection Thing"
  Then I should see "Post To Collection"  
  When I follow "Post To Collection"
  Then I should see "Post New Work"
    And I should see "collection_thing" in the "Post to Collections/Challenges: " input
  When I fill in the basic work information for "My Collected Work"
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see "My Collection Thing" within ".collections"
  When I press "Post"
  Then I should see "My Collected Work"
    And I should see "Collections: My Collection Thing" 
    
  # How about also posting with a recipient?
  When I follow "My Collection Thing"
  Then I should see "Post To Collection"
  When I follow "Post To Collection"
    And I fill in the basic work information for "My Second Collected Work"
    And I fill in "work_recipients" with "myname1"
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see "My Collection Thing" within ".collections"
    And I should see "For myname1"
        
  # Now how about creating a subcollection
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
  When I go to the collections page
    And I follow "New Collection"
    And I fill in "collection_parent_name" with "collection_thing"
    And I fill in "Display Title" with "My SubCollection"
    And I fill in "Collection Name" with "subcollection_thing"
    And I press "Submit"
  Then I should see "Collection was successfully created"
  
  # and posting to that
  When I follow "Log out"
    And I am logged in as "myname2" with password "something"
  When I go to the collections page
    And I follow "My Collection Thing"
    And I follow "Subcollections"
    And I follow "My SubCollection"
    And I follow "Post To Collection"
    And I fill in the basic work information for "My Subcollected Work"
    And I press "Preview"
  Then I should see "Preview Work"
    And I should see "My SubCollection" within ".collections"
    

  