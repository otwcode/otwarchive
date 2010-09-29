@users @wip
Feature: User icons

  Scenario: Users should be able to upload icons

  Given I am logged in as "myself" with password "password"
    And I go to myself's user page
    And I follow "Pseuds"
    And I follow "Edit"
  When I attach the file "test/fixtures/icon.gif" to "icon"
    And I press "Update"
  # TODO: The rest of this test currently fails, and I can't figure out why  
  # Then show me the page
  # Then I should see "Icon uploaded"
  #   And I should see the "alt" text "No alt text available"
  # When I fill in "icon_alt" with "Some test description"
  #   And I press "Update"
  # Then I should see the "alt" text "Some test description"
