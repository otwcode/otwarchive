@users
Feature: Pseuds

Scenario: pseud creation and playing with the default pseud

  Given I am logged in as "myself" with password "password"
    And I go to myself's user page
    And I follow "Pseuds"
    And issue "1186" is fixed
  # Then I should see "Default Pseud" within ".navigation"
  When I follow "Edit"
  Then I should see "cannot change your fallback pseud"
    And issue "1817" is fixed
    # And the "pseud_is_default" checkbox should be checked
    # And the "pseud_is_default" checkbox should be disabled
  When I follow "Back To Pseuds"
    And I follow "New Pseud"
    And I fill in "Name" with "Me"
    And I check "pseud_is_default"
    And I fill in "Description" with "Something's cute"
    And I press "Create"
  Then I should see "Pseud was successfully created."
  When I follow "Edit"
  Then I should see "Me"
    And issue "1186" is fixed
    # And the "Is default" checkbox should be checked
    And the "Is default" checkbox should not be disabled
  When I follow "Back To Pseuds"
    And I follow "Edit myself"
    And issue "1186" is fixed
  # Then the "pseud_is_default" checkbox should not be checked
    # And the "pseud_is_default" checkbox should not be disabled
  # When I follow "Back To Pseuds"
    # And I follow "Me"
    # And I follow "Edit Pseud"
    # And I uncheck "Is default"
    # And I press "Update"
  # Then I should see "Pseud was successfully updated."
  # When I follow "Edit"
  # Then the "Is default" checkbox should not be checked
  # When I follow "Back To Pseuds"
    # And I follow "myself"
    # And I follow "Edit Pseud"
  # Then the "pseud_is_default" checkbox should be checked
    # And the "pseud_is_default" checkbox should be disabled
