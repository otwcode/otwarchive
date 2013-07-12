@tag_sets
Feature: deleting tag sets

  Scenario: A user should be able to delete a tag set
  Given I am logged in as "tagsetter"
    And I go to the tagsets page
    And I follow the add new tagset link
    And I fill in "Title" with "murder_mystery_tags"
    And I submit
    And I should see a create confirmation message
    And I should see "tagsetter" within ".meta"
  When I follow "Delete"
  Then I should see "Tag set was successfully deleted."
