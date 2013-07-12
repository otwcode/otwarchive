@tags @users @tag_wrangling

Feature: Tag Wrangling - Relationships

Scenario: relationship wrangling - syns, mergers, characters, autocompletes

  Given the following activated tag wrangler exists
    | login  | password    |
    | Enigel | wrangulate! |
    And basic tags
    And a fandom exists with name: "Torchwood", canonical: true
    And a character exists with name: "Hoban Washburne", canonical: true
    And a character exists with name: "Zoe Washburne", canonical: true
    And a character exists with name: "Jack Harkness", canonical: true
    And a character exists with name: "Ianto Jones", canonical: true
    And I am logged in as "Enigel" with password "wrangulate!"
    And I follow "Tag Wrangling"
    
  # create a new canonical relationship from tag wrangling interface
    And I follow "New Tag"
    And I fill in "Name" with "Jack Harkness/Ianto Jones"
    And I choose "Relationship"
    And I check "tag_canonical"
    And I press "Create Tag"
  Then I should see "Tag was successfully created"
    And the "tag_canonical" checkbox should be checked
    And the "tag_canonical" checkbox should not be disabled
  
  # create a new non-canonical relationship from tag wrangling interface
  When I follow "New Tag"
    And I fill in "Name" with "Wash/Zoe"
    And I choose "Relationship"
    And I press "Create Tag"
  Then I should see "Tag was successfully created"
    And the "tag_canonical" checkbox should not be checked
    And the "tag_canonical" checkbox should not be disabled
  
  # assigning characters AND a new merger to a non-canonical relationship
  When I fill in "Characters" with "Hoban Washburne, Zoe Washburne"
    And I fill in "Synonym of" with "Hoban Washburne/Zoe Washburne"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should see "Hoban Washburne" within "div#parent_Character_associations_to_remove_checkboxes"
    And I should see "Zoe Washburne" within "div#parent_Character_associations_to_remove_checkboxes"
  When I follow "Hoban Washburne/Zoe Washburne"
  Then I should see "Hoban Washburne" within "div#parent_Character_associations_to_remove_checkboxes"
    And I should see "Zoe Washburne" within "div#parent_Character_associations_to_remove_checkboxes"
    And I should see "Make tag non-canonical and unhook all associations"
    And I should see "Wash/Zoe"
    And the "tag_canonical" checkbox should be checked
    And the "tag_canonical" checkbox should be disabled
    
  # creating a new canonical relationship by renaming
  When I fill in "Synonym of" with "Hoban 'Wash' Washburne/Zoe Washburne"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should not see "Synonyms"
  When I follow "Hoban 'Wash' Washburne/Zoe Washburne"
  Then I should see "Make tag non-canonical and unhook all associations"
    And I should see "Wash/Zoe"
    And I should see "Hoban Washburne/Zoe Washburne"
    And I should see "Hoban Washburne" within "div#parent_Character_associations_to_remove_checkboxes"
    And I should see "Zoe Washburne" within "div#parent_Character_associations_to_remove_checkboxes"
    And the "tag_canonical" checkbox should be checked
    And the "tag_canonical" checkbox should be disabled
  
  # creating non-canonical relationships from work posting
  When I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Torchwood"
    And I fill in "Work Title" with "Silliness"
    And I fill in "Relationships" with "Janto, Jack/Ianto"
    And I fill in "content" with "And then everyone was kidnapped by an alien bus."
    And I press "Preview"
    And I press "Post"
  Then I should see "Work was successfully posted."
  
  # editing non-canonical relationship in order to syn it to existing canonical merger AND add characters
  When I follow "Jack/Ianto"
    And I follow "Edit"
    And I fill in "Synonym of" with "Jack H"
  Then I should find "Jack Harkness/Ianto Jones" within ".autocomplete"
  When I fill in "Synonym of" with "Jack Harkness/Ianto Jones"
    And I fill in "Characters" with "Jack H"
    And I should find "Jack Harkness" within ".autocomplete"
    And I fill in "Characters" with "Jack Harkness, Ianto Jones"
    And I fill in "Fandoms" with "Tor"
    And I should find "Torchwood" within ".autocomplete"
    And I fill in "Fandoms" with "Torchwood"
    And I press "Save changes"
  Then I should see "Tag was updated"
  
  # adding a non-canonical synonym to a canonical, fandom should be copied
  When I follow "Jack Harkness/Ianto Jones"
  Then I should see "Jack Harkness" within "div#parent_Character_associations_to_remove_checkboxes"
    And I should see "Ianto Jones" within "div#parent_Character_associations_to_remove_checkboxes"
    And I should see "Torchwood"
    And I should see "Jack/Ianto"
    And the "tag_canonical" checkbox should be disabled
  When I fill in "tag_merger_string" with "Jant"
  Then I should find "Janto" within ".autocomplete"
  When I fill in "tag_merger_string" with "Janto"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should see "Janto"
  When I follow "Janto"
  Then I should see "Torchwood"
    But I should not see "Jack Harkness" within ".tags"
    And I should not see "Ianto Jones" within ".tags"
  
  # metatags and subtags, transference thereof to a new canonical
  When I follow "Jack Harkness/Ianto Jones"
    And I fill in "MetaTags" with "Jack Harkness/Male Character"
    And I press "Save changes"
  Then I should see "Tag was updated"
    But I should not see "Jack Harkness/Male Character"
  When I follow "New Tag"
    And I fill in "Name" with "Jack Harkness/Male Character"
    And I check "tag_canonical"
    And I choose "Relationship"
    And I press "Create Tag"
    And I fill in "SubTags" with "Jack Harkness"
  Then I should find "Jack Harkness/Ianto Jones" within ".autocomplete"
  When I fill in "SubTags" with "Jack Harkness/Ianto Jones"
    And I press "Save changes"
  Then I should see "Tag was updated"
  When I follow "Jack Harkness/Ianto Jones"
  Then I should see "Jack Harkness/Male Character"
  When I follow "New Tag"
    And I fill in "Name" with "Jack Harkness/Robot Ianto Jones"
    And I choose "Relationship"
    And I check "tag_canonical"
    And I press "Create Tag"
    And I fill in "MetaTags" with "Jack Harkness/Ianto Jones"
    And I press "Save changes"
  Then I should see "Tag was updated"
  When I follow "Jack Harkness/Ianto Jones"
  Then I should see "Jack Harkness/Robot Ianto Jones"
    And I should see "Jack Harkness/Male Character"
  When I fill in "Synonym of" with "Captain Jack Harkness/Ianto Jones"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should not see "Jack Harkness/Robot Ianto Jones"
    And I should not see "Jack Harkness/Male Character"
    And I should not see "Janto"
    And I should not see "Jack/Ianto"
  When I follow "Captain Jack Harkness/Ianto Jones"
  Then I should see "Jack Harkness/Robot Ianto Jones"
    And I should see "Jack Harkness/Male Character"
    And I should see "Janto"
    And I should see "Jack/Ianto"
    And I should see "Jack Harkness/Ianto Jones" within "div#child_Merger_associations_to_remove_checkboxes"
    
  # trying to syn a non-canonical to another non-canonical
  When I follow "New Tag"
    And I fill in "Name" with "James Norrington/Jack Sparrow"
    And I choose "Relationship"
    And I press "Create Tag"
    And I follow "New Tag"
    And I fill in "Name" with "Sparrington"
    And I choose "Relationship"
    And I press "Create Tag"
    And I fill in "Synonym of" with "James Norrington/Jack Sparrow"
    And I press "Save changes"
  Then I should see "James Norrington/Jack Sparrow is not a canonical tag. Please make it canonical before adding synonyms to it."

  # trying to syn a non-canonical to a canonical of a different category
  When I fill in "Synonym of" with "Torchwood"
    And I press "Save changes"
  Then I should see "Torchwood is a fandom. Synonyms must belong to the same category."
  
  Scenario: Issue 962, non-canonical merger pairings
  
  Given the following activated tag wrangler exists
    | login  | password    |
    | Enigel | wrangulate! |
    And basic tags
    And a fandom exists with name: "Testing", canonical: true
    And a relationship exists with name: "Testing McTestypants/Testing McTestySkirt", canonical: true
    And a relationship exists with name: "Testypants/Testyskirt", canonical: false
    And I am logged in as "Enigel" with password "wrangulate!"
    And I follow "Tag Wrangling"
    
  When I edit the tag "Testing McTestypants/Testing McTestySkirt"
    And I fill in "Fandoms" with "Testing"
    And I press "Save changes"
  Then I should see "Tag was updated"
  
  When I edit the tag "Testypants/Testyskirt"
    And I fill in "Synonym of" with "Testing McTestypants/Testing McTestySkirt"
    And I press "Save changes"
  Then I should see "Tag was updated"
  
  When I edit the tag "Testing McTestypants/Testing McTestySkirt"
    # I'm not sure how the line below was ever passing? The checkbox is disabled, and from what I can gather from
    # some wranglers, it is expected behavior.
    # And I uncheck "tag_canonical"
    And I press "Save changes"
  Then I should see "Tag was updated"

  When I post the work "Pants and skirts"
    And I edit the work "Pants and skirts"
    And I fill in "Relationships" with "Testypants/Testyskirt"
    And I press "Preview"
    And I press "Update"
  Then I should see "Work was successfully updated"
  
  When I go to Enigel's works page
  Then I should see "Testypants/Testyskirt"
     And I should see "Testing McTestypants/Testing McTestySkirt"
  When I view the tag "Testing"
  Then I should see "Testing McTestypants/Testing McTestySkirt"
    And I should see "Testypants/Testyskirt"
  When I go to Enigel's user page
  Then I should see "Testypants/Testyskirt"
    And I should not see "Testing McTestypants/Testing McTestySkirt"

  Scenario: Issue 2150: creating a new merger to a non-can tag while adding characters which belong to a fandom
  
  Given the following activated tag wrangler exists
    | login  | password    |
    | Enigel | wrangulate |
    And the following activated user exists
    | login  | password    |
    | writer | password    |
    And basic tags
    And a fandom exists with name: "Up with Testing", canonical: true
    And a fandom exists with name: "Coding", canonical: true
    And a character exists with name: "Testing McTestypants", canonical: true
    And a character exists with name: "Testing McTestySkirt", canonical: true
    
  # create a relationship from posting a work as a regular user, just in case
   Given I am logged in as "writer" with password "password"
    And I follow "New Work"
    And I fill in "Fandoms" with "Up with Testing"
    And I fill in "Work Title" with "whatever"
    And I fill in "Relationships" with "Testypants/Testyskirt"
    And I fill in "content" with "a long story about nothing"
    And I press "Preview"
    And I press "Post"
    And I log out
  
  # wrangle the tags to be as close of those that have errored on beta and test
  When I am logged in as "Enigel" with password "wrangulate"
    And I edit the tag "Coding"
    And I fill in "MetaTags" with "Up with Testing"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should see "Up with Testing"
    
  When I edit the tag "Testing McTestypants"
    And I fill in "Fandoms" with "Up with Testing, Coding"
    And I press "Save changes"
  Then I should see "Tag was updated"
  
  When I edit the tag "Testing McTestySkirt"
    And I fill in "Fandoms" with "Up with Testing, Coding"
    And I press "Save changes"
  Then I should see "Tag was updated"
  
  When I edit the tag "Testypants/Testyskirt"
    And I fill in "Synonym of" with "Testing McTestypants/Testing McTestySkirt"
    And I fill in "Characters" with "Testing McTestypants, Testing McTestySkirt"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should see "Testing McTestypants" within "div#parent_Character_associations_to_remove_checkboxes"
    And I should see "Testing McTestySkirt" within "div#parent_Character_associations_to_remove_checkboxes"
    And I should see "Up with Testing" within "div#parent_Fandom_associations_to_remove_checkboxes"
    And I should see "Coding" within "div#parent_Fandom_associations_to_remove_checkboxes"
  When I follow "Testing McTestypants/Testing McTestySkirt"
  Then I should see "Testing McTestypants" within "div#parent_Character_associations_to_remove_checkboxes"
    And I should see "Testing McTestySkirt" within "div#parent_Character_associations_to_remove_checkboxes"
    And I should see "Up with Testing" within "div#parent_Fandom_associations_to_remove_checkboxes"
    And I should see "Coding" within "div#parent_Fandom_associations_to_remove_checkboxes"
    And I should see "Testypants/Testyskirt"
    And the "tag_canonical" checkbox should be checked
    And the "tag_canonical" checkbox should be disabled
  
  When I edit the tag "Testing McTestypants/Testing McTestySkirt"
    And I fill in "Synonym of" with "Dame Tester/Sir Tester"
    And I press "Save changes"
  Then I should see "Tag was updated"
