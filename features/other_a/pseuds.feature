@users
Feature: Pseuds

Scenario: pseud creation and playing with the default pseud

  Given I am logged in as "myself" with password "password"
    And I go to myself's pseuds page
  Then I should see "Default Pseud" within "div#main.pseuds-index"
  When I follow "Edit"
  Then I should see "cannot change your fallback pseud"
    And the "pseud_is_default" checkbox should be checked
    And the "pseud_is_default" checkbox should be disabled
  When I follow "Back To Pseuds"
    And I follow "New Pseud"
    And I fill in "Name" with "Me"
    And I check "pseud_is_default"
    And I fill in "Description" with "Something's cute"
    And I press "Create"
  Then I should see "Pseud was successfully created."
  When I follow "Edit Pseud"
  Then I should see "Me"
    And the "Make this name default" checkbox should not be disabled
    And the "Make this name default" checkbox should be checked
  When I follow "Back To Pseuds"
    And I follow "edit_myself"
  Then the "pseud_is_default" checkbox should not be checked
    And the "pseud_is_default" checkbox should not be disabled
  When I follow "Back To Pseuds"
    And I follow "Me"
    And I follow "Edit Pseud"
    And I uncheck "Make this name default"
    And I press "Update"
  Then I should see "Pseud was successfully updated."
  When I follow "Edit Pseud"
  Then the "Make this name default" checkbox should not be checked
  When I follow "Back To Pseuds"
    And I follow "edit_myself"
  Then the "pseud_is_default" checkbox should be checked
    And the "pseud_is_default" checkbox should be disabled

Scenario: Manage pseuds - add, edit

  Given I am logged in as "editpseuds"
  When I go to editpseuds's user page
    Then I should see "You don't have anything posted under this name yet"
  When I follow "Profile"
    And I follow "Manage My Pseuds"
  Then I should see "Pseuds for editpseuds"
  When I follow "New Pseud"
  Then I should see "New pseud"
  When I fill in "Name" with "My new name"
    And I fill in "Description" with "I wanted to add another name"
    And I press "Create"
  Then I should see "Pseud was successfully created."
    And I should see "My new name"
    And I should see "You don't have anything posted under this name yet."
    And I should not see "I wanted to add another name"
  When I follow "Back To Pseuds"
  Then I should see "editpseuds (editpseuds)"
    And I should see "My new name (editpseuds)"
    And I should see "I wanted to add another name"
    And I should see "Default Pseud"
  When I follow "editpseuds"
    And I follow "Profile"
    And I follow "Manage My Pseuds"
  Then I should see "Edit My new name"
  When I follow "edit_my_new_name"
    And I fill in "Description" with "I wanted to add another fancy name"
    And I fill in "Name" with "My new fancy name"
    And I press "Update"
  Then I should see "Pseud was successfully updated"
  When I follow "Back To Pseuds"
  Then I should see "editpseuds (editpseuds)"
    And I should see "My new fancy name (editpseuds)"
    And I should see "I wanted to add another fancy name"
    And I should not see "My new name (editpseuds)"
    And I should not see "I wanted to add another name"
