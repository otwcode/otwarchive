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
  When I follow "Edit"
    And I add the character tags "Bababa, Lalala" and the freeform tags "wheee, gloopy" to the tag set "Noncanonical Tags"
  Then I should see an update confirmation message
    And I should see "wheee"
    
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

  Scenario: A moderator should be able to manually set up associations between tags in their set on the main tag set edit page


  # NOMINATIONS
  Scenario: A tag set should take nominations within the nomination limits
  Given I am logged in as "tagsetter"
    And I set up the nominated tag set "Nominated Tags" with 0 fandom noms and 3 character noms
  Then I should see "Nominate"
  When I follow "Nominate"
  Then I should see "You can nominate up to 3 characters"
  
  Scenario: Tag set nominations should nest characters under fandoms if fandoms are being nominated
  Given I am logged in as "tagsetter"
    And I set up the nominated tag set "Nominated Tags" with 3 fandom noms and 3 character noms
  Then I should see "Nominate"
  When I follow "Nominate"
  Then I should see "You can nominate up to 3 fandoms and up to 3 characters for each one"

  Scenario: You should be able to nominate tags
  Given I am logged in as "tagsetter"
    And I set up the nominated tag set "Nominated Tags" with 3 fandom noms and 3 character noms
  Given I nominate 3 fandoms and 3 characters in the "Nominated Tags" tag set as "nominator"
    And I submit
  Then I should see "Your nominations were successfully submitted"
    
  Scenario: If a set has received nominations, a moderator should be able to review nominated tags
  Given I have the nominated tag set "Nominated Tags"
    And I am logged in as "tagsetter"
  When I go to the "Nominated Tags" tag set page
    And I follow "Review Nominations"
  Then I should see "left to review"

  Scenario: If a moderator approves a nominated tag it should no longer appear on the review page and should appear on the tag set page 
  Given I am logged in as "tagsetter"
    And I set up the nominated tag set "Nominated Tags" with 3 fandom noms and 3 character noms
    And I nominate fandom "Floobry" and character "Barblah" in "Nominated Tags"
    And I review nominations for "Nominated Tags"
  Then I should find "Floobry" within ".tagset"
  When I check "fandom_approve_Floobry"
    And I check "character_approve_Barblah"
    And I submit
  Then I should see "Successfully added to set: Floobry"
    And I should see "Successfully added to set: Barblah"
  When I follow "Review Nominations"
  Then I should not see "Floobry"
    And I should not see "Barblah"

  Scenario: If a moderator rejects a nominated tag or its fandom it should no longer appear on the review page
  Given I am logged in as "tagsetter"
    And I set up the nominated tag set "Nominated Tags" with 3 fandom noms and 3 character noms
    And I nominate fandom "Floobry" and character "Barblah" in "Nominated Tags"
    And I review nominations for "Nominated Tags"
  When I check "fandom_reject_Floobry"
    And I submit
  Then I should see "Successfully rejected: Floobry"
    And I should not find "Floobry" within ".tagset"
    And I should not see "Barblah"
    
  Scenario: Tags with brackets should work with replacement
  Given I am logged in as "tagsetter"
    And I set up the nominated tag set "Nominated Tags" with 3 fandom noms and 3 character noms
    And I nominate fandoms "Foo [Bar], Bar [Foo]" and characters "Yar [Bar], Bat [Bar]" in "Nominated Tags"
    And I review nominations for "Nominated Tags"
  When I check "fandom_approve_Foo__LBRACKETBar_RBRACKET"
    And I check "character_reject_Yar__LBRACKETBar_RBRACKET"
    And I check "fandom_approve_Bar__LBRACKETFoo_RBRACKET"
    And I check "character_approve_Bat__LBRACKETBar_RBRACKET"
    And I submit
  Then I should see "Successfully added to set: Bar [Foo], Foo [Bar]"
    And I should see "Successfully added to set: Bat [Bar]"
    And I should see "Successfully rejected: Yar [Bar]"
  When I go to the "Nominated Tags" tag set page
  Then I should see "Foo [Bar]"
    And I should see "Bar [Foo]"
    And I should not see "Yar [Bar]"
  When I go to the "Nominated Tags" tag set page
    And I follow "Review Associations"
  Then I should see "Bat [Bar] → Bar [Foo]"
  When I check "Bat [Bar] → Bar [Foo]"
    And I submit
  Then I should see "Nominated associations were added"
    And I should not see "don't seem to be associated"

  Scenario: Tags with Unicode characters should work
  Given I nominate and approve tags with Unicode characters in "Nominated Tags"
    And I am logged in as "tagsetter"
    And I go to the "Nominated Tags" tag set page
  Then I should see the tags with Unicode characters
  
  # ASSOCIATIONS
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
    
  Scenario: If a nominated tag and its parent are wrangled after approval it should still be possible to associate them
  Given I nominate and approve fandom "Floobry" and character "Zarrr" in "Nominated Tags"
    And a canonical character "Zarrr" in fandom "Floobry"
  When I review associations for "Nominated Tags"
  Then I should see "Zarrr → Floobry"
  When I check "Zarrr → Floobry"
    And I submit
  Then I should see "Nominated associations were added"
    And I should not see "don't seem to be associated"
    
  Scenario: Tags with brackets should work in associations
  
  
    