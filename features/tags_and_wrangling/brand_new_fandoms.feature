@user @tag_wrangling
Feature: Brand new fandoms

  Background:
    # The external works form will error if we don't have basic tags, and since
    # we're trying to create a brand new tag, we just want to double-check that
    # it doesn't exist.
    Given basic tags
      And the tag "My Brand New Fandom" does not exist

  Scenario: Brand new fandoms should be visible on the uncategorized fandoms page.
    Given I am logged in as a random user
      And I post a work "My New Work" with fandom "My Brand New Fandom"
      And The periodic tag count task is run
    When I follow "Uncategorized Fandoms" within "#header"
    Then I should see "My Brand New Fandom"

  Scenario: Fandoms used only on external works should be visible on the uncategorized fandoms page.
    Given I am logged in as a random user
      And I set up an external work
      And I fill in "Fandoms" with "My Brand New Fandom"
      And I submit
      And The periodic tag count task is run
    When I follow "Uncategorized Fandoms" within "#header"
    Then I should see "My Brand New Fandom"

  Scenario: Brand new fandoms should be visible to wranglers.
    Given I am logged in as a tag wrangler
      And I post a work "My New Work" with fandom "My Brand New Fandom"
      And The periodic tag count task is run
    When I follow "Tag Wrangling" within "#header"
      And I follow "Fandoms by media"
    Then I should see "My Brand New Fandom"

  Scenario: Fandoms used only on external works should be visible to wranglers.
    Given I am logged in as a tag wrangler
      And I set up an external work
      And I fill in "Fandoms" with "My Brand New Fandom"
      And I submit
      And The periodic tag count task is run
    When I follow "Tag Wrangling" within "#header"
      And I follow "Fandoms by media"
    Then I should see "My Brand New Fandom"
