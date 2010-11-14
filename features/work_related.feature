@works
Feature: Inspirations, remixes and translations
  In order to reflect the connections between some fanworks
  As a fan author, part of a fan community
  I want to be able to list related works

Scenario: Posting new works with related works, then editing
  Given the following activated users exist
    | login          | password   | email             |
    | inspiration    | something  | test1@example.com |
    | translator     | password   | test2@example.com  |
    | remixer        | password   | test3@example.com  |
    And basic tags
    And all emails have been delivered
    And I have loaded the "languages" fixture
    And I am logged in as "inspiration" with password "something"
    And I post the work "Worldbuilding"
    And I post the work "Worldbuilding Two"
    And I am logged out

  # posting a remix / inspired-by work

  When I am logged in as "remixer" with password "password"
    And I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Stargate"
    And I fill in "Work Title" with "Followup"
    And I fill in "content" with "That could be an amusing crossover."
    And I list the work "Worldbuilding" as inspiration
    And I press "Preview"
  Then I should see "Draft was successfully created"
  When I press "Post"
  Then I should see "Work was successfully posted"
    And I should see "Inspired by Worldbuilding by inspiration"
    And 1 email should be delivered

  # check that I see it under related works

  When I go to remixer's user page
  Then I should see "My Related Works (1)"
  When I follow "My Related Works"
  Then I should see "Works remixer's works were inspired by"
    And I should see "Worldbuilding by inspiration"
  When I am logged out
    And all emails have been delivered

  # posting a translation

  When I am logged in as "translator" with password "password"
    And I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Stargate"
    And I fill in "Work Title" with "Followup Translated"
    And I fill in "content" with "That could be an amusing crossover."
    And I list the work "Followup" as inspiration
    And I check "This is a translation"
    And I select "Deutsch" from "Choose a language"
    And I press "Preview"
  Then I should see "Draft was successfully created"
  When I press "Post"
  Then I should see "Work was successfully posted"
    And I should see "A translation of Followup by remixer"
    And 1 email should be delivered

  # check that I see it under related works

  When I go to translator's user page
  Then I should see "My Related Works (1)"
  When I follow "My Related Works"
  Then I should see "Works translator's works were inspired by"
    And I should see "Followup by remixer"
    And I should see "From English to Deutsch"

  # check that unapproved rels do not appear on the original

  When I view the work "Worldbuilding"
  Then I should not see "Followup"
  When I view the work "Followup"
  Then I should not see "Followup Translated"

  # approve relationships and check they appear on the original, then remove and check

  When I am logged out
    And I am logged in as "inspiration" with password "something"
    And I go to inspiration's user page
  Then I should see "My Related Works (1)"
  When I follow "My Related Works"
  Then I should see "Works inspired by inspiration's works"
    And I should see "Followup by remixer"
  When I follow "Approve"
  Then I should see "Approve Link"
  When I press "Yes, link me!"
  Then I should see "Link was successfully approved"
    And I should see "Works inspired by this one:"
    And I should see "Followup by remixer"
  When I follow "my home"
  Then I should see "My Related Works (1)"
  When I follow "My Related Works"
    And I follow "Remove"
  Then I should see "Remove Link"
  When I press "Remove link"
  Then I should see "Link was successfully removed"
    And I should not see "Followup by remixer"
  When I am logged out
    And I am logged in as "remixer" with password "password"
    And I go to remixer's user page
  Then I should see "My Related Works (2)"
  When I follow "My Related Works"
  Then I should see "Works remixer's works were inspired by"
    And I should see "Works inspired by remixer's works"
    And I should see "Followup Translated by translator"
    And I should see "From English to Deutsch"
  When I follow "Approve" within "#inspiredbyme"
    And I press "Yes, link me!"
  Then I should see "Link was successfully approved"
    And I should see "Translation into Deutsch available:" within ".notes"
    And I should see "Followup Translated by translator" within ".notes"
    And I should see "Works inspired by this one:"
    And I should see "Followup Translated by translator" within "li"
  When I go to remixer's user page
    And I follow "My Related Works"
    And I follow "Remove" within "#inspiredbyme"
  Then I should see "Remove Link"
  When I press "Remove link"
  Then I should see "Link was successfully removed"
    And I should not see "Translation into Deutsch available:" within ".notes"
    And I should not see "Followup Translated by translator" within ".notes"
    And I should not see "Works inspired by this one:"
    And I should not see "Followup Translated by translator" within "li"

  # editing existing work should also send email

  When I edit the work "Followup"
    And all emails have been delivered
    And I list the work "Worldbuilding Two" as inspiration
    And I press "Preview"
  Then I should see "Preview Work"
  When I press "Update"
  Then I should see "Work was successfully updated"
    And I should see "Inspired by Worldbuilding Two by inspiration"
    And "issue 1509" is fixed
    # And 1 email should be delivered

Scenario: Listing external works as inspirations
  Given basic tags
  When I am logged in as "remixer" with password "password"
    And I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Stargate"
    And I fill in "Work Title" with "Followup"
    And I fill in "content" with "That could be an amusing crossover."
    And I check "parent-options-show"
    And I fill in "Url" with "google.com"
    And I press "Preview"
  Then I should see "We couldn't save this Work, sorry"
    And I should see "A parent work outside the archive needs to have a title."
    And I should see "A parent work outside the archive needs to have an author."
  When I fill in "Title" with "Worldbuilding"
    And I fill in "Author" with "BNF"
    And I check "This is a translation"
    And I press "Preview"
  Then I should see "Draft was successfully created"
  When I press "Post"
  Then I should see "Work was successfully posted"
    And I should see "A translation of Worldbuilding by BNF"
  When I edit the work "Followup"
    And I check "parent-options-show"
    And I fill in "Url" with "testarchive.transformativeworks.org"
    And "issue 1806" is fixed
    # And I press "Preview"
  # Then I should see "We couldn't save this work, sorry"
    # And I should see "A parent work outside the archive needs to have a title."
    # And I should see "A parent work outside the archive needs to have an author."
  When I fill in "Title" with "Worldbuilding Two"
    And I fill in "Author" with "BNF"
    And I press "Preview"
  Then I should see "Preview Work"
  When I press "Update"
  Then I should see "Work was successfully updated"
    And I should see "A translation of Worldbuilding by BNF"
    And I should see "Inspired by Worldbuilding Two by BNF"

# TO DO after issue 1741 is resolved
# Scenario: Test that I can remove relationships that I initiated from my own works
# especially during posting / editing / previewing a work
