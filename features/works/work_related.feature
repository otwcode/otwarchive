@works
Feature: Inspirations, remixes and translations
  In order to reflect the connections between some fanworks
  As a fan author, part of a fan community
  I want to be able to list related works

Scenario: Posting a remix / inspired-by work should email the original author
  Given I have related works setup
  When I post a related work
  Then a related work should be seen
    And the original author should be emailed

Scenario: check that remixer can see a remix under related works

  Given I have related works setup
  When I post a related work
  When I go to my user page
  Then I should see "Related Works (1)"
  When I follow "Related Works"
  Then I should see "Works that inspired remixer"
    And I should see "Worldbuilding by inspiration"
    
Scenario: Author can see a remix under related works

  Given I have related works setup
  When I post a related work
  When I am logged in as "inspiration"
    And I view my related works
  Then I should see "Works inspired by inspiration"
    And I should see "Followup by remixer"

Scenario: Can post a translation and it emails the original author

  Given I have related works setup
  When I post a translation
  Then I should see "Work was successfully posted"
    And I should see "A translation of Worldbuilding by inspiration"
    And 1 email should be delivered

Scenario: Translator sees a translation under related works

  Given I have related works setup
  When I post a translation
  When I go to my user page
  Then I should see "Related Works (1)"
  When I follow "Related Works"
  Then I should see "Works translated by translator"
    And I should see "Worldbuilding by inspiration"
    And I should see "From English to Deutsch"

Scenario: Unapproved rels do not appear on the original

  Given I have related works setup
  When I post a translation
  When I view the work "Worldbuilding"
  Then I should not see "Translated"
  
Scenario: Can approve a relationship

  Given I have related works setup
  When I post a related work
  When I am logged in as "inspiration"
    And I view my related works
  When I follow "Approve"
  Then I should see "Approve Link"
  When I press "Yes, link me!"
  Then I should see "Link was successfully approved"
    And I should see "Works inspired by this one:"
    And I should see "Followup by remixer"

Scenario: Approve a translation and see it linked in the preface

  Given I have related works setup
  When I post a translation
  When I approve a related work
  Then I should see "Link was successfully approved"
    And I should see "Translation into Deutsch available:" within ".preface .notes"
    And I should not see "Works inspired by this one:"
    
Scenario: Approved work appears

  Given I have related works setup
  When I post a translation
  When I approve a related work
  When I view the work "Worldbuilding"
  Then I should see "Translated"
    
Scenario: Related works links appear in the right places

  Given I have related works setup
    And I am logged in as "testuser"
    And I post the work "Parent Work"
  When I am logged in as "inspiration"
    And I edit the work "Worldbuilding"
    And I list the work "Parent Work" as inspiration
    And I press "Post Without Preview"
  Then I should see "Work was successfully"
  When I post a related work
    And I approve a related work
    And I post a translation
    And I approve a related work
  Then I should see "Translation into Deutsch available:" within ".preface .notes"
    And I should see "Worldbuilding Translated" within ".preface .notes"
    And I should see "Inspired by Parent Work by testuser" within ".preface .notes"
    And I should see "(See the end of the work for other works inspired by this one.)" within ".preface .notes"
    And I should see "Works inspired by this one:" within ".afterword .children"
    And I should see "Followup by remixer" within ".afterword .children"
    And I should not see "Worldbuilding Translated" within ".afterword .children"

Scenario: See approved and unapproved relationships on the related works page as an author

  Given I have related works setup
  When I post a translation
    And I post a related work
  When I approve a related work
  When I view my related works
  Then I should see "Worldbuilding Approve"
    And I should see "Deutsch Remove"
    
Scenario: Cannot see someone else's related works page

  Given I have related works setup
  When I post a related work
  When I am logged in as "inspiration"
  When I go to remixer's user page
  Then I should not see "Related Works"

Scenario: Remove a previously approved relationship

  Given I have related works setup
  When I post a related work
  When I approve a related work
  When I view my related works
    And I follow "Remove"
  Then I should see "Remove Link"
  When I press "Remove link"
  Then I should see "Link was successfully removed"
    And I should not see "Followup by remixer"
    
Scenario: Remove a previously approved translation

  Given I have related works setup
    And a translation has been posted
  When I approve a related work
  When I view my related works
    And I follow "Remove" within "#translationsofme"
  Then I should see "Remove Link"
  When I press "Remove link"
  Then I should see "Link was successfully removed"
    And I should not see "Translation into Deutsch available:"
    And I should not see "Worldbuilding Translated by translator"
    And I should not see "Works inspired by this one:"

Scenario: editing existing work should also send email

  Given I have related works setup
  When I post a related work
  When I edit the work "Followup"
    And all emails have been delivered
    And I list the work "Worldbuilding Two" as inspiration
    And I press "Preview"
  When I press "Update"
  Then I should see "Work was successfully updated"
    And I should see "Inspired by Worldbuilding Two by inspiration"
    And "issue 1509" is fixed
    # And 1 email should be delivered

Scenario: Remixer receives comments on remix, author doesn't

  Given I have related works setup
  When I post a related work
    And all emails have been delivered
  When I am logged in as "commenter"
  When I post the comment "Blah" on the work "Followup"
  Then "remixer" should be emailed
    And "inspiration" should not be emailed
    
Scenario: Translator receives comments on translation, author doesn't

  Given I have related works setup
    And a translation has been posted
    And all emails have been delivered
  When I am logged in as "commenter"
  When I post the comment "Blah" on the work "Worldbuilding Translated"
  Then "translator" should be emailed
    And "inspiration" should not be emailed

Scenario: Author chooses to receive comments on translation

  #Given I have related works setup
  #  And a translation has been posted
  #  And all emails have been delivered
  #When I am logged in as "inspiration"
  #  And I approve a related work
  #  And I set my preferences to receive comments on translated works
  #When I am logged in as "commenter"
  #  And I post the comment "Blah" on the work "Worldbuilding Translated"
  #Then "translator" should be emailed
  #  And "inspiration" should be emailed

Scenario: Author doesn't receive comments if they haven't approved the translation

  #Given I have related works setup
  #  And a translation has been posted
  #  And all emails have been delivered
  #When I am logged in as "inspiration"
  #  And I set my preferences to receive comments on translated works
  #When I am logged in as "commenter"
  #When I post the comment "Blah" on the work "Worldbuilding Translated"
  #Then "inspiration" should not be emailed
  
Scenario: Can post a translation of a mystery work

Scenario: Posting a translation of a mystery work should not allow you to see the work

Scenario: Can post a translation of an anonymous work

Scenario: Posting a translation of an anonymous work should not allow you to see the author

Scenario: Translate your own work
  Given I have related works setup
  When I post a translation of my own work
    And I approve a related work
  Then approving the related work should succeed

Scenario: Draft works should not show up on related works
  Given I have related works setup
    And I am logged in as "translator"
    And I draft a translation
  When I am logged in as "inspiration"
    And I view my related works
  Then I should not see "Worldbuilding Translated"

@work_external_parent
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
  Then I should see a save error message
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
  # Then I should see a save error message
    # And I should see "A parent work outside the archive needs to have a title."
    # And I should see "A parent work outside the archive needs to have an author."
  When I fill in "Title" with "Worldbuilding Two"
    And I fill in "Author" with "BNF"
    And I press "Preview"
  Then I should see "Preview"
  When I press "Update"
  Then I should see "Work was successfully updated"
    And I should see "A translation of Worldbuilding by BNF"
    And I should see "Inspired by Worldbuilding Two by BNF"
  When I view my related works
  Then I should see "From N/A to English"
  #invalid URL should give a helpful message (issue 1786)
  When I edit the work "Followup"
    And I check "parent-options-show"
    And I fill in "Url" with "this.is.an.invalid/url"
    And I fill in "Title" with "Worldbuilding Two"
    And I fill in "Author" with "BNF"
    And I press "Preview"
  Then I should see "Parent work info would not save."
    
@work_external_language
Scenario: External work language    

  Given basic tags
  Given basic languages
  When I am logged in as "remixer" with password "password"
    And I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Stargate"
    And I fill in "Work Title" with "Followup 4"
    And I fill in "content" with "That could be an amusing crossover."
    And I check "parent-options-show"
    And I fill in "Url" with "www.google.com"
    And I fill in "Title" with "German Worldbuilding"
    And I fill in "Author" with "BNF"
    And I select "Deutsch" from "Language"
    And I check "This is a translation"    
    And I press "Preview"
  Then I should see "Draft was successfully created"
  When I press "Post"
  Then I should see "Work was successfully posted"
    And I should see "A translation of German Worldbuilding by BNF"
  When I view my related works
  Then I should see "From Deutsch to English"
    And I should not see "From N/A to English"
    
# TODO after issue 1741 is resolved
# Scenario: Test that I can remove relationships that I initiated from my own works
# especially during posting / editing / previewing a work
# especially from the related_works page, which works but redirects to a non-existant page right now

Scenario: Restricted works listed as Inspiration show up [Restricted] for guests
  Given I have related works setup
    When I post a related work
    And I approve a related work
    And I am logged in as "remixer"
    And I edit the work "Followup"
    And I check "work_restricted"
    And I press "Post Without Preview"
    And I am logged out
    And I view the work "Worldbuilding"
  Then I should see "A [Restricted Work] by remixer"
    And I am logged in as "remixer"
    And I edit the work "Followup"
    And I uncheck "work_restricted"
    And I press "Post Without Preview"
    And I am logged out
    And I view the work "Followup"
    And I should see "Inspired by Worldbuilding by inspiration"
  When I am logged in as "inspiration"
    And I edit the work "Worldbuilding"
    And I check "work_restricted"
    And I press "Post Without Preview"
    And I am logged out
    And I view the work "Followup"
  Then I should see "Inspired by [Restricted Work] by inspiration"
