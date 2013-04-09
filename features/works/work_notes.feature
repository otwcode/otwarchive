@works
Feature: Display work notes
  In order to provide information about my work
  As an author
  I want to be able to add notes to my work

  Scenario: User posts a work without notes
    Given basic tags
      And I am logged in as a random user
    When I go to the new work page
      And I fill in the basic work information for "A Work"
      And I press "Post Without Preview"
    Then I should not see "Notes:"
    
  Scenario: User posts a work with notes
    Given basic tags
      And I am logged in as a random user
    When I go to the new work page
      And I fill in the basic work information for "A Work"
      And I check "front-notes-options-show"
      And I fill in "work_notes" with "Monkeys"
      And I press "Post Without Preview"
    Then I should see "Notes:"
      And I should see "Monkeys"