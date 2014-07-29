@works @comments

Feature: View a work with various options

  Scenario: viewing a work in explicit View Full Work mode, with JavaScript turned off (Issue 2205)

  Given the chaptered work with 2 comments "Whatever"
  When I view the work "Whatever" in full mode
    And I follow "Comments (2)"
  Then I should see "Bla bla"

  Scenario: viewing a work when logged in and having set full mode in the preferences

  Given I am logged in as a random user
    And I set my preferences to View Full Work mode by default
    And the chaptered work "Whatever"
  When I view the work "Whatever"
  Then I should see "Chapter 2"

  Scenario: viewing a work and chapter that have been deleted
  Given I am logged in as a random user
    And I view a deleted work
    And I should see "Sorry, we couldn't find the work you were looking for."
    And I should see "Welcome to the Archive of Our Own!"
    And I follow "Site Map"
    And I should not see "Sorry, we couldn't find the work you were looking for."



  Scenario: viewing a deleted chapter on a work that still exists
  Given I am logged in as a random user
    And I view a deleted chapter
    And I should see "Sorry, we couldn't find the chapter you were looking for."
    And I should see "DeletedChapterWork"
    And I follow "Site Map"
  Then I should not see "Sorry, we couldn't find the chapter you were looking for."



