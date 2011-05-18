@tag_sets
Feature: creating and editing tag sets
  
  Scenario: A user should be able to create a tag set
  Given I am logged in as "tagsetter"
    And I go to the tagsets page
    And I follow the add new tagset link
    And I fill in the tagset data
    And I submit
  Then I should see a confirmation message
    And I should see the tagset data
  
