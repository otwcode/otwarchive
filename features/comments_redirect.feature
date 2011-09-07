Feature: Posting a comment should result in a friendly redirect

Scenario: Posting a top level comment on a one-chapter work
  Given I have a work "Blabla"
    And I am logged in as a random user
  When I view the work "Blabla"
    And I post a comment "blaaaaaa"
  Then I should see "Blabla"
    And I should see "blaaaaaa"

Scenario: Posting top level comment on middle chapter of chaptered work, with default preferences
  Given the chaptered work setup
    And I am logged in as a random user
  When I view the work "Gimme Comments"
    And I view the 2nd chapter
    And I post a comment "Woohoo"
  Then I should see "Woohoo"
    And I should see "Chapter 2"
    And I should not see "Chapter 1"

Scenario: Posting top level comment on a chaptered work, while in temporary view full mode, with default preferences
  Given the chaptered work setup
    And I am logged in as a random user
  When I view the work "Gimme Comments" in full mode
    And I post a comment "Woohoo"
  Then I should see "Woohoo"
    And I should see "Chapter 2"
    And I should see "Chapter 3"

Scenario: Posting top level comment on a chaptered work, with view full work in the preferences
  Given the chaptered work setup
    And I am logged in as a random user
    And I set my preferences to View Full Work mode by default
  When I view the work "Gimme Comments"
    And I post a comment "Woohoo"
  Then I should see "Woohoo"
    And I should see "Chapter 2"
    And I should see "Chapter 3"

Scenario: Posting top level comment on a middle chapter, while in temporary view by chapter mode, with view full work in the preferences
  Given the chaptered work setup
    And I am logged in as a random user
    And I set my preferences to View Full Work mode by default
  When I view the work "Gimme Comments" in chapter-by-chapter mode
    And I view the 2nd chapter
    And I post a comment "Woohoo"
  Then I should see "Woohoo"
    And I should see "Chapter 2"
    And I should not see "Chapter 1"

Scenario: Posting a reply comment to a comment on a middle chapter, with default settings
  Given the chaptered work with comments setup
    And I am logged in as a random user
    And I view the work "Gimme Comments"
    And I view the 2nd chapter
    And I follow "Read Comments"
  When I reply to a comment with "Supercalifragelistic"
  Then I should see "Supercalifragelistic"
