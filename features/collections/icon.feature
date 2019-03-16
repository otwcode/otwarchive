@users
Feature: User icons

  Scenario: Users should be able to upload icons

  Given I am editing a pseud
  When I attach the file "features/fixtures/icon.gif" to "icon"
    And I press "Update"
  Then I should see "Pseud was successfully updated"
    And I should see the image "alt" text ""

  Scenario: Users can change alt text

  Given I have an icon uploaded
  When I follow "Edit Pseud"
    And I fill in "pseud_icon_alt_text" with "Some test description"
    And I press "Update"
  Then I should see the image "alt" text "Some test description"

  Scenario: Add and remove a collection icon

  Given I have a collection "Pretty"
  When I add an icon to the collection "Pretty"
  Then I should see "Collection was successfully updated"
    And the "Pretty" collection should have an icon
  When I delete the icon from the collection "Pretty"
  Then I should see "Collection was successfully updated."
    And the "Pretty" collection should not have an icon
