@users
Feature: Saved Works

  Scenario: only see own saved works
    Given the following activated user exists
    | login          | password   |
    | first_reader        | password   |
  When I am logged in as "second_reader"
    And I go to first_reader's saved works page
    Then I should see "Sorry, you don't have permission"
    And I should not see "Saved Works" within "div#dashboard"
  When I go to second_reader's reading page
    Then I should see "Saved Works" within "div#dashboard"

  Scenario: Save a work for later
  
  Given I am logged in as "writer"
  When I post the work "Testy"
    Then I should see "Work was successfully posted"
  When I am logged out
    And I am logged in as "reader"
    And I view the work "Testy"
    Then I should see a "Add to saved list" button
  When I press "Add to saved list"
    Then I should see a "Remove from saved list" button
  When I go to reader's saved works page
    Then I should see "Testy"
  When I view the work "Testy"
    Then I should see a "Remove from saved list" button
  When I press "Remove from saved list"
    Then I should see a "Add to saved list" button
  When I go to reader's saved works page
    Then I should not see "Testy"
  
  Scenario: You can't save a work for later if you're not logged in or the author
  
  Given I am logged in as "writer"
  When I post the work "Testy"
  Then I should see "Work was successfully posted"
  When I view the work "Testy"
  Then I should not see a "Add to saved list" button
    And I should not see a "Remove from saved list" button
  When I am logged out
    And I view the work "Testy"
  Then I should not see a "Add to saved list" button
    And I should not see a "Remove from saved list" button
