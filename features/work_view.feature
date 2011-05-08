@works

Feature: View a work with various options

  Scenario: viewing a work in explicit View Full Work mode, with JavaScript turned off (Issue 2205)
  
  Given I view the chaptered work with 2 comments "Whatever" in full mode
  When I follow "Read Comments (2)"
  Then I should see "Bla bla"

  Scenario: viewing a work when logged in and having set full mode in the preferences
  
  Given I am logged in as a random user
    And I set my preferences to View Full Work mode by default
  When I view the chaptered work "Whatever"
  Then I should see "Chapter 2"
