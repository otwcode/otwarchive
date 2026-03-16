@works @comments

Feature: View a work with various options

  Scenario: viewing a work in explicit View Full Work mode, with JavaScript turned off (Issue 2205)
  Given the chaptered work with 2 comments "Whatever"
  When I view the work "Whatever" in full mode
    And I follow "Comments (2)"
  Then I should see "Bla bla"

  Scenario: Regular logged-in user doesn't have the option to troubleshoot a work
  Given the work "Whatever"
    And I am logged in
   When I view the work "Whatever"
   Then I should not see "Troubleshoot"

  Scenario: Logged-out user doesn't have the option to troubleshoot a work
  Given the work "Whatever"
    And I am a visitor
   When I view the work "Whatever"
   Then I should not see "Troubleshoot"

  Scenario: viewing a work when logged in and having set full mode in the preferences
  Given the chaptered work "Whatever"
    And I am logged in as a random user
    And I set my preferences to View Full Work mode by default
  When I view the work "Whatever"
  Then I should see "Chapter 2"

  Scenario: viewing a work and chapter that have been deleted
  Given I am logged in as a random user
    And I view a deleted work
  Then I should be on the homepage
    And I should see "Sorry, we couldn't find the work you were looking for."
  When I follow "Site Map"
    And I should not see "Sorry, we couldn't find the work you were looking for."

  Scenario: viewing a deleted chapter on a work that still exists
  Given I am logged in as a random user
    And I view a deleted chapter
    And I should see "Sorry, we couldn't find the chapter you were looking for."
    And I should see "DeletedChapterWork"
    And I follow "Site Map"
  Then I should not see "Sorry, we couldn't find the chapter you were looking for."

  Scenario: other users cannot collect a work by default
  Given the work "Whatever"
  When I have the collection "test collection" with name "test_collection"
    And I am logged in as "moderator"
    And I view the work "Whatever"
  Then I should not see a link "Invite To Collections"
    And I should not see the "new_collection_item" form

  Scenario: other users can collect a work when the creator has opted-in
  Given the work "Whatever"
    And I am logged in as the author of "Whatever"
    And I set my preferences to allow collection invitations
  When I have the collection "test collection" with name "test_collection"
    And I am logged in as "moderator"
    And I view the work "Whatever"
  Then I should see a link "Invite To Collections"
    And I should see the "new_collection_item" form

  Scenario: archivists can add works to collections regardless of invitation preferences
  Given the work "Imported Work"
    And I have an archivist "archivist"
    And I am logged in as "archivist"
  When I create the collection "Open Doors Collection 1"
    And I view the work "Imported Work"
  Then I should see a link "Add to Collections"
    And I should see the "new_collection_item" form

  Scenario: chapter title displays in View Full Work mode when chaptered work has one published chapter
  Given I am logged in as a random user
    And I set my preferences to View Full Work mode by default
  When I set up the draft "multiChap"
    And I check "This work has multiple chapters"
    And I fill in "Chapter Title" with "cool chapter title"
    And I fill in "Chapter 1 of" with "?"
    And I press "Post"
  Then I should see "Chapter 1: "
    And I should see "cool chapter title"

  Scenario: Works and chapters include the navigation, meta, work skin CSS, and
  preface, except in preview mode, which contains more limited information.
    Given the work skin "Flair" by "carbon"
      And I am logged in as "carbon"
      And I set up the draft "Elemental"
      And I select "Flair" from "Select work skin"
    When I press "Preview"
    Then I should see the work meta
      And I should see the work preface
      And I should see the work styles
      But I should not see the work header navigation
    When I press "Post"
    Then I should see the work header navigation
      And I should see the work meta
      And I should see the work preface
      And I should see the work styles
    When I follow "Add Chapter"
      And I fill in "content" with "My chapter's text."
      And I press "Preview"
    Then I should see the work styles
      But I should not see the work header navigation
      And I should not see the work meta
      And I should not see the work preface
    When I press "Post"
    Then I should see the work header navigation
      And I should see the work meta
      And I should see the work preface
      And I should see the work styles
