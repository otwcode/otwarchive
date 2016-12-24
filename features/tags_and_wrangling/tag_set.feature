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

  Scenario: You should be able to edit your nominated tag sets, but cannot delete them once they've been reviewed
  Given I am logged in as "tagsetter"
    And I set up the nominated tag set "Mayfly" with 3 fandom noms and 3 character noms
  When I nominate fandom "Floobry" and character "Barblah" in "Mayfly"
  Then I should see "Not Yet Reviewed (may be edited or deleted)"
    And I should see "Floobry"
  When I follow "Edit"
    And I fill in "tag_set_nomination_fandom_nominations_attributes_0_tagname" with "Bloob"
  When I press "Submit"
  Then I should see "Your nominations were successfully updated"
  Given I am logged in as "tagsetter"
  When I review nominations for "Mayfly"
  Then I should see "Bloob" within ".tagset"
  When I check "fandom_approve_Bloob"
    And I press "Submit"
  Then I should see "Successfully added to set: Bloob"
  Given I am logged in as "nominator"
    And I go to the tagsets page
    And I follow "Mayfly"
    And I follow "My Nominations"
  Then I should see "Partially Reviewed (unreviewed nominations may be edited)"
  When I follow "Edit"
  Then I should not see the field "tag_set_nomination_fandom_nominations_attributes_0_tagname" within "div#main"

  Scenario: Owner of a tag set can clear all nominations
  Given I am logged in as "tagsetter"
    And I set up the nominated tag set "Nominated Tags" with 3 fandom noms and 3 character noms
  Given I nominate 3 fandoms and 3 characters in the "Nominated Tags" tag set as "nominator"
    And I submit
  Then I should see "Your nominations were successfully submitted"
  Given I am logged in as "tagsetter"
  When I review nominations for "Nominated Tags"
    And I follow "Clear Nominations"
    And I press "Yes, Clear Tag Set Nominations"
  Then I should see "All nominations for this Tag Set have been cleared"

  Scenario: Owner of a tag set with over 30 nominations sees a message that they can't all be displayed on one page
  Given I am logged in as "tagsetter"
    And I set up the nominated tag set "Nominated Tags" with 6 fandom noms and 6 character noms
  When there are 36 unreviewed nominations
  Given I am logged in as "tagsetter"
    And I review nominations for "Nominated Tags"
  Then I should see "There are too many nominations to show at once, so here's a randomized selection! Additional nominations will appear after you approve or reject some"

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
  Then I should see "Floobry" within ".tagset"
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
    And I should not see "Floobry" within ".tagset"
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

  # Note this is now testing the non-JS method for deleting your own nominations
  Scenario: You should be able to delete your nominations
    Given I am logged in as "tagsetter"
      And I set up the nominated tag set "Nominated Tags" with 3 fandom noms and 3 character noms
    Given I nominate 3 fandoms and 3 characters in the "Nominated Tags" tag set as "nominator"
      And I submit
    When I should see "Your nominations were successfully submitted"
      And I go to the "Nominated Tags" tag set page
      And I follow "My Nominations"
      And I should see "My Nominations for Nominated Tags"
      And I follow "Delete"
      And I should see "Delete Tag Set Nomination?"
    When I press "Yes, Delete Tag Set Nominations"
    Then I should see "Your nominations were deleted."


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

  Scenario: Batch load character tags should successfully load characters that are canonical and return characters that are not
  Given a fandom exists with name: "MASH (TV)", canonical: true
    And a fandom exists with name: "Dallas (TV)", canonical: true
    And a character exists with name: "Hawkeye Pierce", canonical: true
    And a character exists with name: "Maxwell Klinger", canonical: true
    And a character exists with name: "Henry Blake", canonical: true
    And a character exists with name: "J. R. Ewing", canonical: true
    And a character exists with name: "Sue Ellen Ewing", canonical: true
  When I am logged in as "tagsetter"
    And I set up the tag set "Batch Loading Characters" with a visible tag list
    And I follow "Batch Load"
  When I fill in "Batch Load Tag Associations" with
    """
    MASH (TV),Hawkeye Pierce,Maxwell Klinger,Henry Blake
    Dallas (TV), J. R. Ewing, Sue Ellen Ewing, Pam Ewing
    """
    And I press "Submit"
  Then I should see "We couldn't add all the tags and associations you wanted -- the ones left below didn't work. See the help for suggestions!"
    And I should see "Dallas (TV),Pam Ewing"
    And I should not see "MASH (TV),Hawkeye Pierce,Maxwell Klinger,Henry Blake"
    And I should not see "Dallas (TV), J. R. Ewing, Sue Ellen Ewing, Pam Ewing"
  When I go to the "Batch Loading Characters" tag set page
  Then I should see "MASH (TV)"
    And I should see "Hawkeye Pierce"
    And I should see "Maxwell Klinger"
    And I should see "Henry Blake"
    And I should see "Dallas (TV)"
    And I should see "J. R. Ewing"
    And I should see "Sue Ellen Ewing"
    And I should not see "Pam Ewing"

  Scenario: Batch load relationship tags should successfully load relationships that are canonical and return characters that are not
  Given a fandom exists with name: "MASH (TV)", canonical: true
    And a fandom exists with name: "Dallas (TV)", canonical: true
    And a relationship exists with name: "BJ/Hawkeye", canonical: true
    And a relationship exists with name: "Hawkeye/Margaret Houlihan", canonical: true
    And a relationship exists with name: "Hawkeye & Radar", canonical: true
    And a relationship exists with name: "J. R. Ewing/Sue Ellen Ewing", canonical: true
    And a relationship exists with name: "Ann Ewing/Bobby Ewing", canonical: true
  When I am logged in as "tagsetter"
    And I set up the tag set "Batch Loading Relationships" with a visible tag list
    And I follow "Batch Load"
  When I fill in "Batch Load Tag Associations" with
    """
    MASH (TV), BJ/Hawkeye, Hawkeye/Margaret Houlihan, Hawkeye & Radar
    Dallas (TV),J. R. Ewing/Sue Ellen Ewing,Ann Ewing/Sue Ellen Ewing,Ann Ewing/Bobby Ewing
    """
    And I check "Relationships instead?"
    And I press "Submit"
  Then I should see "We couldn't add all the tags and associations you wanted -- the ones left below didn't work. See the help for suggestions!"
    And I should see "Dallas (TV),Ann Ewing/Sue Ellen Ewing"
    And I should not see "MASH (TV), BJ/Hawkeye, Hawkeye/Margaret Houlihan, Hawkeye & Radar"
    And I should not see "Dallas (TV),J. R. Ewing/Sue Ellen Ewing,Ann Ewing/Sue Ellen Ewing,Ann Ewing/Bobby Ewing"
  When I go to the "Batch Loading Relationships" tag set page
  Then I should see "MASH (TV)"
    And I should see "BJ/Hawkeye"
    And I should see "Hawkeye/Margaret Houlihan"
    And I should see "Hawkeye & Radar"
    And I should see "Dallas (TV)"
    And I should see "J. R. Ewing/Sue Ellen Ewing"
    And I should see "Ann Ewing/Bobby Ewing"
    And I should not see "Ann Ewing/Sue Ellen Ewing"
