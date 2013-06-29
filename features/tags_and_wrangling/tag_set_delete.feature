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
    And I should see "Delete Tag Set?"
    And I should see "Are you certain you want to delete the murder_mystery_tags Tag Set?"
    And I press "Yes, Delete Tag Set"
  Then I should see "Your Tag Set murder_mystery_tags was deleted"
