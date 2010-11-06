@users
Feature: User icons

  Scenario: Users should be able to upload icons

  Given I am logged in as "myself" with password "password"
    And I go to myself's user page
    And I follow "Pseuds"
    And I follow "Edit"
  When I attach the file "test/fixtures/icon.gif" to "icon"
    And I press "Update"
  Then I should see "Pseud was successfully updated"
    And I should see the "alt" text ""
  When I follow "Edit"
    And I fill in "pseud_icon_alt_text" with "Some test description"
    And I press "Update"
  Then I should see the "alt" text "Some test description"
