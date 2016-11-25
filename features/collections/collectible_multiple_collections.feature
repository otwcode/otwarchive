@bookmarks @collections @works

Feature: Collectible items in multiple collections
  As a user
  I want to be unable to add items to more than one collection

  Scenario: Add a work that is already in a moderated collection to a second
  moderated collection using the Add to Collections option on the work
    Given I have the moderated collection "ModeratedCollection"
      And I have the moderated collection "ModeratedCollection2"
      And I am logged in as a random user
      And I post the work "Blabla" to the collection "ModeratedCollection"
    When I view the work "Blabla"
      And I fill in "Collection name(s):" with "ModeratedCollection2"
      And I press "Add"
    Then I should see "You have submitted your work to the moderated collection 'ModeratedCollection2'."
      And I should see "It will not become a part of the collection until it has been approved by a moderator."
    When I follow "Edit"
      And I press "Post Without Preview"
    Then I should see "Work was successfully updated. You have submitted your work to moderated collections (ModeratedCollection, ModeratedCollection2). It will not become a part of those collections until it has been approved by a moderator."

  Scenario: Add my work to both moderated and unmoderated collections by editing 
  the work
    Given I have the moderated collection "ModeratedCollection"
      And I have the collection "UnModeratedCollection"
      And I am logged in as a random user
      And I post the work "RandomWork" to the collection "ModeratedCollection"
    When I go to "ModeratedCollection" collection's page
    Then I should not see "RandomWork"
    When I edit the work "RandomWork"
      # Fill in both the existing and new collection names or else this will
      # remove it from the original collection by replacing the text in the
      # field
      And I fill in "Post to Collections / Challenges" with "ModeratedCollection, UnModeratedCollection"
      And I press "Post Without Preview"
    Then I should see "Work was successfully updated. You have submitted your work to the moderated collection 'ModeratedCollection'. It will not become a part of the collection until it has been approved by a moderator."
      And I should see "UnModeratedCollection"
    When I go to "UnModeratedCollection" collection's page
    Then I should see "RandomWork"
    When I go to "ModeratedCollection" collection's page
    Then I should not see "RandomWork"

