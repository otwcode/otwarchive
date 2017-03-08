# encoding: utf-8
@tag_sets
Feature: creating and editing tag sets

  Scenario: A user should be able to create a tag set with a title
  Given I am logged in as "tagsetter"
    And I go to the tagsets page
    And I follow the add new tagset link
    And I fill in "Title" with "Empty Tag Set"
    And I submit
  Then I should see a create confirmation message
    And I should see "About Empty Tag Set"
    And I should see "tagsetter" within ".meta"

  Scenario: A user should be able to create a tag set with noncanonical tags
  Given I am logged in as "tagsetter"
    And I set up the tag set "Noncanonical Tags" with the fandom tags "Ywerwe, Blah di blah, Foooo"
  Then I should see a create confirmation message
    And I should see "Ywerwe"

  Scenario: A user should be able to add additional tags to an existing set
  Given I am logged in as "tagsetter"
    And I set up the tag set "Noncanonical Tags" with the fandom tags "Ywerwe, Blah di blah, Foooo"
  When I add the character tags "Bababa, Lalala" and the freeform tags "wheee, gloopy" to the tag set "Noncanonical Tags"
  Then I should see an update confirmation message
    And I should see "wheee"

  Scenario: A user should be able to add and remove fandom tags for a tag set they own
  Given I am logged in
    And I set up the tag set "Fandoms" with the fandom tags "One, Two"
  When I add the fandom tags "Three, Four" to the tag set "Fandoms"
  Then I should see "One"
    And I should see "Two"
    And I should see "Three"
    And I should see "Four"
  When I remove the fandom tags "One, Three" from the tag set "Fandoms"
  Then I should see "Two"
    And I should see "Four"
    And I should not see "One"
    And I should not see "Three"

  Scenario: A user should be able to add and remove character tags for a tag set they own
  Given I am logged in
    And I set up the tag set "Characters" with the character tags "Character 1, Character 2"
  When I add the character tags "Character 3, Character 4" to the tag set "Characters"
  Then I should see "Character 1"
    And I should see "Character 2"
    And I should see "Character 3"
    And I should see "Character 4"
  When I remove the character tags "Character 2, Character 4" from the tag set "Characters"
  Then I should see "Character 1"
    And I should see "Character 3"
    And I should not see "Character 2"
    And I should not see "Character 4"

  Scenario: A user should be able to add and remove relationship tags for a tag set they own
  Given I am logged in
    And I set up the tag set "Relationships" with the relationship tags "One/Two, 1 & 2"
  When I add the relationship tags "3/4, Three & Four" to the tag set "Relationships"
  Then I should see "One/Two"
    And I should see "1 & 2"
    And I should see "3/4"
    And I should see "Three & Four"
  When I remove the relationship tags "One/Two, Three & Four" from the tag set "Relationships"
  Then I should see "1 & 2"
    And I should see "3/4"
    And I should not see "One/Two"
    And I should not see "Three & Four"

  Scenario: A user should be able to add and remove rating tags for a tag set they own
  Given the default ratings exist
    And I am logged in
    And I set up the tag set "Ratings" with the rating tags "Explicit, Mature"
  When I add the rating tags "Teen And Up Audiences, General Audiences" to the tag set "Ratings"
  Then I should see "Explicit"
    And I should see "Mature"
    And I should see "Teen And Up Audiences"
    And I should see "General Audiences"
  When I remove the rating tags "Explicit, Teen And Up Audiences" from the tag set "Ratings"
  Then I should see "Mature"
    And I should see "General Audiences"
    And I should not see "Explicit"
    And I should not see "Teen And Up Audiences"

  Scenario: A user should be able to add and remove category tags for a tag set they own
  Given the basic categories exist
    And I am logged in
    And I set up the tag set "Categories" with the category tags "Other, F/M"
  When I add the category tags "F/F, M/M" to the tag set "Categories"
  Then I should see "Other"
    And I should see "F/M"
    And I should see "M/M"
    And I should see "F/F"
  When I remove the category tags "F/F, Other" from the tag set "Categories"
  Then I should see "M/M"
    And I should see "F/M"
    And I should not see "F/F"
    And I should not see "Other"

  Scenario: A user should be able to add and remove warning tags for a tag set they own
  Given the basic warnings exist
    And I am logged in
    And I set up the tag set "Warnings" with the warning tags "Choose Not To Use Archive Warnings"
  When I add the warning tags "No Archive Warnings Apply" to the tag set "Warnings"
  Then I should see "Choose Not To Use Archive Warnings"
    And I should see "No Archive Warnings Apply"
  When I remove the warning tags "Choose Not To Use Archive Warnings" from the tag set "Warnings"
  Then I should see "No Archive Warnings Apply"
    And I should not see "Choose Not To Use Archive Warnings"

  Scenario: If a tag set does not have a visible tag list, only a moderator should be able to see the tags in the set, but everyone should be able to see the tag set
  Given I am logged in as "tagsetter"
    And I set up the tag set "Tag Set with Non-visible Tag List" with an invisible tag list and the fandom tags "Dallas, Knots Landing, Models Inc"
  Then I should see "Dallas"
    And I should see "Knots Landing"
    And I should see "Models Inc"
  When I go to the tagsets page
  Then I should see "Tag Set with Non-visible Tag List"
  When I log out
    And I go to the tagsets page
  Then I should see "Tag Set with Non-visible Tag List"
  When I follow "Tag Set with Non-visible Tag List"
  Then I should not see "Dallas"
    And I should not see "Knots Landing"
    And I should not see "Models Inc"
    And I should see "The moderators have chosen not to make the tags in this set visible to the public (possibly while nominations are underway)."

  Scenario: If a tag set has a visible tag list, everyone should be able to see the tags in the set
  Given I am logged in as "tagsetter"
    And I set up the tag set "Tag Set with Visible Tag List" with a visible tag list and the fandom tags "Dallas, Knots Landing, Models Inc"
  Then I should see "Dallas"
    And I should see "Knots Landing"
    And I should see "Models Inc"
  When I log out
    And I view the tag set "Tag Set with Visible Tag List"
  Then I should see "Dallas"
    And I should see "Knots Landing"
    And I should see "Models Inc"
