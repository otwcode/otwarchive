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

  # TODO
  # Scenario: Tags with brackets should work in associations
