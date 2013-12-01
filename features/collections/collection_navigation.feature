@collections
Feature: Basic collection navigation

  Scenario: Create a collection and check the links
  When I am logged in as "mod" with password "password"
    And I go to the collections page
    And I follow "New Collection"
    And I fill in "Collection Name" with "my_collection"
    And I fill in "Display Title" with "My Collection"
    And I submit
  Then I should see "Collection was successfully created."
    And I should see "Works (0)"
    And I should see "Fandoms (0)"
  Given basic tags
    And I have a canonical "TV Shows" fandom tag named "New Fandom"
    And a freeform exists with name: "Free", canonical: true
  When I follow "New Work" within "ul.user.navigation.actions"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "New Fandom"
    And I fill in "Additional Tags" with "Free"
    And I fill in "Work Title" with "Work for my collection"
    And I fill in "content" with "First because I'm the mod"
    And I fill in "Post to Collections / Challenges" with "my_collection"
    And I press "Preview"
    And I press "Post"
    And I follow "My Collection"
  When I follow "Profile"
  Then I should see "About My Collection (my_collection)"
    And I should see "Maintainers: mod"
  When I follow "Subcollections (0)"
  Then I should see "Challenges/Subcollections in My Collection"
    And I should see "Sorry, there were no collections found."
  When I follow "Fandoms (1)"
  Then I should see "New Fandom (1)"
  When I follow "Works (1)"
  Then I should see "Work for my collection by mod"
    And I should see "1 Work in My Collection"
  When I follow "Bookmarks (0)"
  Then I should see "0 Bookmarks"
  When I follow "Random Items"
  Then I should see "Work for my collection by mod"
  When I follow "People" within "div#dashboard"
    Then I should see "A Random Selection of Participants in My Collection"
    And I should see "mod"
  When I follow "Tags" within "div#dashboard"
    Then I should see "Free"
  When I follow "Collection Settings"
    Then I should see "Edit Collection"
  When I am logged out
    And I am on the collections page
    And I follow "My Collection"
  Then I should not see "Settings"

  Scenario: A Collection's Fandoms should be in alphabetical order
  Given I have the collection "My ABCs" with name "my_abcs"
    And a canonical fandom "A League of Their Own"
    And a canonical fandom "Merlin"
    And a canonical fandom "Teen Wolf"
    And a canonical fandom "The Borgias"
  When I am logged in as "Scott" with password "password"
    And I post the work "Sesame Street" in the collection "My ABCs"
    And I edit the work "Sesame Street"
    And I fill in "Fandoms" with "A League of Their Own, Merlin, Teen Wolf, The Borgias"
    And I press "Post Without Preview"
    And I go to "My ABCs" collection's page
    And I follow "Fandoms ("
  Then "The Borgias" should appear before "A League of Their Own"
    And "A League of Their Own" should appear before "Merlin"
    And "Merlin" should appear before "Teen Wolf"


