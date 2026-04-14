@tags
Feature: View Tags
  In order to find more tags
  As a user
  I want to see how tags are related

  Scenario: Only wrangled tags appear in child tag listing
    Given the canonical fandom "Canonical Fandom" with 0 works
      And I am logged in
    When I post the work "Cool Work" with fandom "Canonical Fandom" with character "My Character" with freeform "My Freeform"
      And all indexing jobs have been run
      And I view the tag "Canonical Fandom"
    Then I should not see "Child tags"
    # Ensure the cache key changes when the tag is updated
    When it is currently 1 second from now
      And I add the fandom "Canonical Fandom" to the character "My Character"
      And I add the fandom "Canonical Fandom" to the tag "My Freeform"
      And all indexing jobs have been run
      And I view the tag "Canonical Fandom"
    Then I should see "Child tags"
      And I should see "My Character"
      And I should see "My Freeform"

  Scenario: Media tags list child fandoms
    Given I have a canonical "TV Shows" fandom tag named "Steven Universe"
      And all indexing jobs have been run
    When I view the tag "TV Shows"
    Then I should see "Child tags"
      And I should see "Steven Universe"

  Scenario: Lists all synonymous tags
    Given a freeform exists with name: "Rain", canonical: true
      And a synonym "It's raining" of the tag "Rain"
      And all indexing jobs have been run
      And I view the tag "Rain"
    Then I should see "Tags with the same meaning"
      And I should see "It's raining"
      And I should not see "Child tags"
    And I view the tag "It's raining"
      And I should not see "Tags with the same meaning"
      And I should see "has been made a synonym of Rain"

  Scenario: The number of child tag listings are limited, and the most popular are displayed in alphabetical order
    Given a canonical relationship "C/D" in fandom "Canonical Fandom"
      And a canonical relationship "E/F" in fandom "Canonical Fandom"
      And a canonical relationship "a/b" in fandom "Canonical Fandom"
      And I am logged in
      And I post the work "Cool Work" with fandom "Canonical Fandom" with relationship "E/F"
      And I post the work "Cooler Work" with fandom "Canonical Fandom" with relationship "a/b"
      And I post the work "Coolest Work" with fandom "Canonical Fandom" with relationship "E/F"
      And the tag list limit is 2
      And all indexing jobs have been run
    When I view the tag "Canonical Fandom"
    Then "a/b" should appear before "E/F"
      And I should not see "C/D"
      And I should see "and more"

  Scenario: Child tags link to the proper page urls with escaped symbols
    Given a canonical relationship "#&A/B.?" in fandom "Canonical Fandom"
      And all indexing jobs have been run
    When I view the tag "Canonical Fandom"
    Then I should see a page link to the "#&A/B.?" tag page within "//div[@class='child listbox group']"
