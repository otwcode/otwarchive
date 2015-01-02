@works
Feature: Inspirations, remixes and translations
  In order to reflect the connections between some fanworks
  As a fan author, part of a fan community
  I want to be able to list related works

Scenario: Posting a remix / related work emails the creator of the original work and lists the parent work in the proper location on the remix / related work

  Given I have related works setup
  When I post a related work as remixer
  Then a parent related work should be seen
    And the original author should be emailed

Scenario: Remixer can see their remix / related work on their related works page

  Given I have related works setup
  When I post a related work as remixer
  When I go to my user page
  Then I should see "Related Works (1)"
  When I follow "Related Works"
  Then I should see "Works that inspired remixer"
    And I should see "Worldbuilding by inspiration"
    
Scenario: Creator of original work can see a remix on their related works page

  Given I have related works setup
    And a related work has been posted
  When I am logged in as "inspiration"
    And I view my related works
  Then I should see "Works inspired by inspiration"
    And I should see "Followup by remixer"

Scenario: Posting a translation emails the creator of the original work and lists the parent work in the proper location on the translation

  Given I have related works setup
  When I post a translation as translator
  Then a parent translated work should be seen
    And the original author should be emailed

Scenario: Translator can see their translation on their related works page

  Given I have related works setup
  When I post a translation as translator
  When I go to my user page
  Then I should see "Related Works (1)"
  When I follow "Related Works"
  Then I should see "Works translated by translator"
    And I should see "Worldbuilding by inspiration"
    And I should see "From English to Deutsch"
    
Scenario: Creator of original work can see a translation on their related works page

  Given I have related works setup
    And a translation has been posted
  When I am logged in as "inspiration"
    And I view my related works
  Then I should see "Translations of inspiration's works"
    And I should see "Worldbuilding Translated by translator"
    And I should see "From English to Deutsch"

Scenario: Unapproved translations do not appear or produce an associations list on the original work

  Given I have related works setup
  When I post a translation as translator
  When I view the work "Worldbuilding"
  Then I should not see the translation listed on the original work
    And I should not find a list for associations

Scenario: Unapproved related works do not appear or produce an associations list on the original work

  Given I have related works setup
  When I post a related work as remixer
  When I view the work "Worldbuilding"
  Then I should not see the related work listed on the original work
    And I should not find a list for associations
  
Scenario: The creator of the original work can approve a related work that is NOT a translation and see it referenced in the beginning notes and linked in the end notes

  Given I have related works setup
    And a related work has been posted
  When I am logged in as "inspiration"
    And I view my related works
  When I follow "Approve"
  Then I should see "Approve Link"
  When I press "Yes, link me!"
  Then I should see "Link was successfully approved"
    And I should see a beginning note about related works
    And I should see the related work in the end notes
    And I should not find a list for associations

Scenario: The creator of the original work can approve a translation and see it linked in an associations list in the beginning notes, and there should not be a list of "works inspired by this one"

  Given I have related works setup
    And a translation has been posted
  When I approve a related work
  Then I should see "Link was successfully approved"
    And I should see the translation in the beginning notes
    And I should not see "Works inspired by this one:"
    And I should find a list for associations
    
Scenario: Translation, related work, and parent work links appear in the right places even when viewing a multi-chapter work with draft chapters in chapter-by-chapter mode

  Given I have related works setup
    And a translation has been posted and approved
    And a related work has been posted and approved
    And an inspiring parent work has been posted
  When I am logged in as "inspiration"
    And I edit the work "Worldbuilding"
    And I list the work "Parent Work" as inspiration
    And I press "Post Without Preview"
    And a chapter is added to "Worldbuilding"
    And a draft chapter is added to "Worldbuilding"
  When I view the work "Worldbuilding"
  Then I should find a list for associations
    And I should see a beginning note about related works
    And I should see the translation in the beginning notes
    And I should see the inspiring parent work in the beginning notes
  When I follow "other works inspired by this one"
  Then I should see the related work in the end notes
    And I should not see the translation in the end notes

Scenario: The creator of the original work can see approved and unapproved relationships on their related works page

  Given I have related works setup
    And a translation has been posted
    And a related work has been posted
  When I approve a related work
  When I view my related works
  Then I should see "Worldbuilding Approve"
    And I should see "Deutsch Remove"
    
Scenario: A user cannot see another user's related works page

  Given I have related works setup
    And a related work has been posted
  When I am logged in as "inspiration"
  When I go to remixer's user page
  Then I should not see "Related Works"
  When I go to remixers's related works page
  # It's currently possible to access a user's related works page directly
  # Then I should see "Sorry, you don't have permission to access the page you were trying to reach."

Scenario: The creator of the original work can remove a previously approved related work

  Given I have related works setup
    And a related work has been posted and approved
  When I view my related works
    And I follow "Remove"
  Then I should see "Remove Link"
  When I press "Remove link"
  Then I should see "Link was successfully removed"
    And I should not see the related work listed on the original work
    
Scenario: The creator of the original work can remove a previously approved translation

  Given I have related works setup
    And a translation has been posted and approved
  When I view my related works
    And I follow "Remove" within "#translationsofme"
  Then I should see "Remove Link"
  When I press "Remove link"
  Then I should see "Link was successfully removed"
    And I should not see the translation listed on the original work

Scenario: Editing an existing work to add an inspiration (parent work) should send email to the creator of the original work

  Given I have related works setup
  When I post a related work as remixer
    And I edit the work "Followup"
    And all emails have been delivered
    And I list the work "Worldbuilding Two" as inspiration
    And I press "Preview"
  When I press "Update"
  Then I should see "Work was successfully updated"
    And I should see "Inspired by Worldbuilding Two by inspiration"
    And "issue 1509" is fixed
    # And 1 email should be delivered

Scenario: Remixer receives comments on remix, creator of original work doesn't

  Given I have related works setup
    And a related work has been posted
    And all emails have been delivered
  When I am logged in as "commenter"
  When I post the comment "Blah" on the work "Followup"
  Then "remixer" should be emailed
    And "inspiration" should not be emailed
    
Scenario: Translator receives comments on translation, creator of original work doesn't

  Given I have related works setup
    And a translation has been posted
    And all emails have been delivered
  When I am logged in as "commenter"
  When I post the comment "Blah" on the work "Worldbuilding Translated"
  Then "translator" should be emailed
    And "inspiration" should not be emailed

Scenario: Creator of original work chooses to receive comments on translation

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

Scenario: Creator of original work doesn't receive comments if they haven't approved the translation

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
    And I go to my user page
  Then I should not see "Related Works (1)"
  When I view my related works
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
    And basic languages
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
    And a related work has been posted and approved
  When I am logged in as "remixer"
    And I lock the work "Followup"
  When I am logged out
    And I view the work "Worldbuilding"
  Then I should see "A [Restricted Work] by remixer"
  When I am logged in as "remixer"
    And I unlock the work "Followup"
  When I am logged out
    And I view the work "Followup"
  Then I should see "Inspired by Worldbuilding by inspiration"
  When I am logged in as "inspiration"
    And I lock the work "Worldbuilding"
  When I am logged out
    And I view the work "Followup"
  Then I should see "Inspired by [Restricted Work] by inspiration"

  Scenario: When a user is notified that a co-authored work has been inspired by a work they posted, the e-mail should link to each author's URL instead of showing escaped HTML
  Given I have related works setup
    And I am logged in as "inspiration"
    And I post the work "Seed of an Idea"
  When I am logged in as "inspired"
    And I set up the draft "Seedling of an Idea"
    And I add the co-author "misterdeejay"
    And I list the work "Seed of an Idea" as inspiration
    And I preview the work
    And I post the work
  Then 1 email should be delivered to "misterdeejay"
    And the email should contain "You have been listed as a coauthor on the following work"
  Then 1 email should be delivered to "inspiration"
    And the email should link to inspired's user url
    And the email should not contain "&lt;a href=&quot;http://archiveofourown.org/users/inspired/pseuds/inspired&quot;"
    And the email should link to misterdeejay's user url
    And the email should not contain "&lt;a href=&quot;http://archiveofourown.org/users/misterdeejay/pseuds/misterdeejay&quot;"
  