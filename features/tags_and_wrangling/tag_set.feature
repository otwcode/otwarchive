@tag_sets
Feature: creating and editing tag sets
  
  Scenario: A user should be able to create a tag set with a title
  Given I am logged in as "tagsetter"
    And I go to the tagsets page
    And I follow the add new tagset link
    And I fill in "Title" with "Empty Tag Set"
    And I submit
  Then I should see a create confirmation message
    And I should see "About Empty Tag Set"
    And I should see "tagsetter" within ".meta"
  
  Scenario: A user should be able to create a tag set with noncanonical tags
  Given I am logged in as "tagsetter"
    And I set up the tag set "Noncanonical Tags" with the fandom tags "Ywerwe, Blah di blah, Foooo"
  Then I should see a create confirmation message
    And I should see "Ywerwe"
    
  Scenario: A user should be able to add additional tags to an existing set
  Given I am logged in as "tagsetter"
    And I set up the tag set "Noncanonical Tags" with the fandom tags "Ywerwe, Blah di blah, Foooo"
  When I follow "Edit"
    And I add the character tags "Bababa, Lalala" and the freeform tags "wheee, gloopy" to the tag set "Noncanonical Tags"
  Then I should see an update confirmation message
    And I should see "wheee"
    
  Scenario: If a set is not visible, only a moderator should be able to see the tags in the set

  Scenario: A moderator should be able to manually set up associations between tags in their set on the main tag set edit page


  # NOMINATIONS
  Scenario: If a set is taking nominations, a user should be able to submit nominations within the nomination limits
  
  Scenario: If a set has received nominations, a moderator should be able to review nominated tags
  Scenario: If a moderator rejects a nominated tag it should no longer appear on the review page
  Scenario: If a moderator approves a nominated tag it should no longer appear on the review page and should appear on the tag set page 
  