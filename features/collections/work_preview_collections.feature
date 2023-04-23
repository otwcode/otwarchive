Feature: Previewing collection changes on works
  Background:
    Given a collection "Assortment"
      And I am logged in as a random user

  Scenario: Adding a collection and previewing shows the collection on the preview
    Given I post the work "Collectible"
    When I edit the work "Collectible"
      And I fill in "Post to Collections / Challenges" with "Assortment"
      And I press "Preview"
    Then I should see "Assortment"

  Scenario: Adding a collection, previewing, and cancelling doesn't add the collection
    Given I post the work "Collectible"
    When I edit the work "Collectible"
      And I fill in "Post to Collections / Challenges" with "Assortment"
      And I press "Preview"
      And I press "Cancel"
      And I view the work "Collectible"
    Then I should not see "Assortment"

  Scenario: Adding a collection, previewing, and updating adds the collection
    Given I post the work "Collectible"
    When I edit the work "Collectible"
      And I fill in "Post to Collections / Challenges" with "Assortment"
      And I press "Preview"
      And I press "Update"
      And I view the work "Collectible"
    Then I should see "Assortment"

  Scenario: Removing a collection and previewing hides the collection on the preview
    Given I post the work "Collectible" to the collection "Assortment"
    When I edit the work "Collectible"
      And I fill in "Post to Collections / Challenges" with ""
      And I press "Preview"
    Then I should not see "Assortment"

  Scenario: Removing a collection, previewing, and cancelling doesn't remove the collection
    Given I post the work "Collectible" to the collection "Assortment"
    When I edit the work "Collectible"
      And I fill in "Post to Collections / Challenges" with ""
      And I press "Preview"
      And I press "Cancel"
      And I view the work "Collectible"
    Then I should see "Assortment"

  Scenario: Removing a collection, previewing, and updating removes the collection
    Given I post the work "Collectible" to the collection "Assortment"
    When I edit the work "Collectible"
      And I fill in "Post to Collections / Challenges" with ""
      And I press "Preview"
      And I press "Update"
      And I view the work "Collectible"
    Then I should not see "Assortment"
