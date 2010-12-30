@collections
Feature: Basic collection navigation

  Scenario: Create a collection and check the links
  When I am logged in as "mod" with password "password"
    And I go to the collections page
    And I follow "New Collection"
    And I fill in "Collection Name" with "my_collection"
    And I fill in "Display Title" with "My Collection"
    And I press "Submit"
  Then I should see "Collection was successfully created."
    And I should see "Works (0)"
    And I should see "Fandoms (0)"
  Given basic tags
    And I have a canonical "TV Shows" fandom tag named "New Fandom"
    And a freeform exists with name: "Free", canonical: true
  When I post the work "Work for my collection"
    And I edit the work "Work for my collection"
    And I fill in "Post to Collections/Challenges" with "my_collection"
    And I press "Preview"
    And I press "Update"
    And I follow "My Collection"
  When I follow "Profile"
  Then I should see "About My Collection (my_collection)"
    And I should see "Maintainers: mod"
  When I follow "Subcollections (0)"
  Then I should see "Challenges/Subcollections in My Collection"
    And I should see "Sorry, there were no collections found."
  When I follow "Works (1)"
  Then I should see "Work for my collection by mod"
    And I should see "1 Work found in My Collection"
  When I follow "Random Items"
  Then I should see "Work for my collection by mod"
  When I go to "My Collection" collection's static page
  Then I should see "All Fandoms"
    And I should see "Locked Works"
    And I should see "Welcome to My Collection!"

