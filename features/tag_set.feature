@tag_sets
Feature: creating and editing tag sets
  
  Scenario: A user should be able to create a tag set
  Given I am logged in as "tagsetter"
  When I go to the tagsets page
  Then I should see "New Tag Set"
  When I follow "New Tag Set"
    And I fill in "Title" with "My Tagset"
    And I fill in "Brief Description" with "Here's my tagset"
    And I fill in "Fandoms to add:" with "Supernatural, Smallville, Stargate: SG-1"
    And I press "Submit"
  Then I should see "Tag set was created successfully"
    And I should see "My Tagset"
    And I should see "Here's my tagset"
    And I should see "tagsetter" within ".meta"
    And I should see "Supernatural"
