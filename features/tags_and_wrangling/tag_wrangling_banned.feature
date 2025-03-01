@tags @tag_wrangling
Feature: Banned tags

  Scenario: Wranglers do not have the option to create banned tags or change
  other tags to banned tags
    Given I am logged in as a tag wrangler
    When I go to the new tag page
    Then I should not see "Banned" within "#new_tag"
    When I fill in "Name" with "Not A Banned Tag"
      And I choose "Fandom"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."
    And "Fandom" should be selected within "tag_type"
      # Make sure we can't see admin-only option
      And "Banned" should not be an option within "tag_type"

  Scenario: Admins can create banned tags and then make them canonical
    Given I am logged in as a "tag_wrangling" admin
    When I go to the new tag page
      And I fill in "Name" with "New Banned 1"
      And I choose "Banned"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."
      And "Banned" should be selected within "tag_type"
      # Make sure we can see regular wrangling option
      And "Fandom" should be an option within "tag_type"
    When I check "Canonical"
      And I press "Save changes"
    Then I should see "Tag was updated."
      And the "New Banned 1" tag should be canonical
      And the "New Banned 1" tag should be a "Banned" tag

  Scenario: Admins can recategorize tags into banned tags
    Given I am logged in as a "tag_wrangling" admin
    When I go to the new tag page
      And I fill in "Name" with "Ambiguous Tag"
      And I choose "Fandom"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."
      And "Fandom" should be selected within "tag_type"
    When I select "Banned" from "tag_type"
      And I press "Save changes"
    Then I should see "Tag was updated."
      And the "Ambiguous Tag" tag should be a "Banned" tag

  Scenario: Admins can recategorize banned tags into other types
    Given I am logged in as a "tag_wrangling" admin
    When I go to the new tag page
      And I fill in "Name" with "Ambiguous Tag"
      And I choose "Banned"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."
      And "Banned" should be selected within "tag_type"
    When I select "Character" from "tag_type"
      And I press "Save changes"
    Then I should see "Tag was updated."
      And the "Ambiguous Tag" tag should be a "Character" tag
