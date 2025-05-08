# encoding: utf-8
@tag_sets
Feature: Reviewing tag set associations

  Scenario: If a nominated tag and its parent are approved they should appear on the associations page
  Given I nominate and approve fandom "Floobry" and character "Zarrr" in "Nominated Tags"
    And I am logged in as "tagsetter"
    And I go to the "Nominated Tags" tag set page
  Then I should see "don't seem to be associated"
  When I follow "Review Associations"
  Then I should see "Zarrr → Floobry"
  When I check "Zarrr → Floobry"
    And I submit
  Then I should see "Nominated associations were added"
    And I should not see "don't seem to be associated"

  Scenario: If a nominated tag is wrangled into its nominated parent after approval, it should be automatically associated with the parent
  Given I nominate and approve fandom "Floobry" and character "Zarrr" in "Nominated Tags"
    And the tag "Floobry" is canonized
    And I add the fandom "Floobry" to the character "Zarrr"
    And the tag "Zarrr" is canonized
  When I review associations for "Nominated Tags"
  Then I should not see "Zarrr → Floobry"
  # TODO: Remove this step when AO3-3757 is fixed:
  When the cache for the tag set "Nominated Tags" is expired
    And I view the tag set "Nominated Tags"
  Then I should not see "Unassociated Characters & Relationships"
    And I should not see "don't seem to be associated"
    And "Zarrr" should be associated with the "Uncategorized" fandom "Floobry"

  Scenario: If a nominated tag is wrangled to a different fandom after approval, it should still be possible to associate them
  Given I nominate and approve fandom "Floobry" and character "Zarrr" in "Nominated Tags"
    And a canonical fandom "Barbar"
    And I add the fandom "Barbar" to the character "Zarrr"
    And the tag "Zarrr" is canonized
  When I review associations for "Nominated Tags"
  Then I should see "Zarrr → Floobry"
  When I check "Zarrr → Floobry"
    And I submit
  Then I should see "Nominated associations were added"
    And I should not see "Unassociated Characters & Relationships"
    And I should not see "don't seem to be associated"
    And "Zarrr" should be associated with the "Uncategorized" fandom "Floobry"

  Scenario: If a tag set does not exist, no one should be able to see its associations
  Given I am logged in as "tagsetter"
  When I view associations for a tag set that does not exist
  Then I should see "What tag set did you want to look at?"
    And I should be on the tagsets page
  When I log out
    And I view associations for a tag set that does not exist
  Then I should see "What tag set did you want to look at?"
    And I should be on the tagsets page

  Scenario: Nominating a canonical tag in its fandom does not generate associations for review
    Given a canonical character "Jack Carter" in fandom "Eureka"
      And I nominate and approve fandom "Eureka" and character "Jack Carter" in "Canonical Associations"
    When I review associations for "Canonical Associations"
    Then I should not see "Jack Carter"
      And I should not see "Eureka"

  Scenario: Nominating a canonical tag in another fandom generates associations for review
    Given a canonical character "Nathan Stark" in fandom "Eureka"
      And I nominate and approve fandom "Iron Man" and character "Nathan Stark" in "Canonical Associations"
    When I review associations for "Canonical Associations"
    Then I should see "Nathan Stark → Iron Man"
      But I should not see "Eureka"

  Scenario: Nominating a non-canonical tag in its own fandom generates associations for review
    Given a canonical character "Jack Carter" in fandom "Eureka"
      And a non-canonical character "Nathan Carter" in fandom "Eureka"
      And I am logged in as "tagsetter"
      And I set up the nominated tag set "Non-canonical Associations" with 1 fandom nom and 2 character noms
      And I nominate fandom "Eureka" and characters "Jack Carter,Nathan Carter" in "Non-canonical Associations" as "tagsetter"
    When I review nominations for "Non-canonical Associations"
      And I approve the nominated fandom tag "Eureka"
      And I approve the nominated character tag "Jack Carter"
      And I approve the nominated character tag "Nathan Carter"
      And I press "Submit"
      And I review associations for "Non-canonical Associations"
    Then I should see "Nathan Carter → Eureka"

  Scenario: When a nominated non-canonical is renamed, its associations remain for review
    Given a canonical character "Jack Carter" in fandom "Eureka"
      And a non-canonical character "nathan carter" in fandom "Nathan Stark"
      And I am logged in as "tagsetter"
      And I set up the nominated tag set "Non-canonical Associations" with 1 fandom nom and 2 character noms
      And I nominate fandom "Eureka" and characters "Jack Carter,nathan carter" in "Non-canonical Associations" as "tagsetter"
    When I am logged in as a tag wrangler
      And I edit the tag "nathan carter"
      And I fill in "Name" with "Nathan Carter"
      And I press "Save changes"
    Then I should see "Tag was updated"
    When I am logged in as "tagsetter"
      And I review nominations for "Non-canonical Associations"
      And I approve the nominated fandom tag "Eureka"
      And I approve the nominated character tag "Jack Carter"
      And I approve the nominated character tag "nathan carter"
      And I press "Submit"
      And I review associations for "Non-canonical Associations"
    Then I should see "Nathan Carter → Eureka"

  Scenario: Nominating a new tag in an approved fandom generates associations for review
    Given a canonical fandom "Eureka"
      And I am logged in as "tagsetter"
      And I set up the nominated tag set "New Associations" with 1 fandom nom and 2 character noms
      And I nominate fandom "Eureka" and character "Jack Stark" in "New Associations" as "tagsetter"
    When I review nominations for "New Associations"
      And I approve the nominated fandom tag "Eureka"
      And I press "Submit"
      And I edit nominations for "tagsetter" in "New Associations" to include characters "Jack Stark,Nathan Stark" under fandom "Eureka"
      And I review nominations for "New Associations"
    Then I should see "Jack Stark"
      And I should see "Nathan Stark"
    When I approve the nominated character tag "Jack Stark"
      And I approve the nominated character tag "Nathan Stark"
      And I press "Submit"
      And I review associations for "New Associations"
    Then I should see "Jack Stark → Eureka"
      And I should see "Nathan Stark → Eureka"

  # TODO
  # Scenario: Tags with brackets should work in associations
