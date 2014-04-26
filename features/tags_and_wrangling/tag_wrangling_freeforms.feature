@tags @users @tag_wrangling

Feature: Tag Wrangling - Freeforms

Scenario: freeforms wrangling - syns, mergers, autocompletes, metatags

  Given the following activated tag wrangler exists
    | login  | password    |
    | Enigel | wrangulate! |
    And basic tags
    And I am logged in as "Enigel" with password "wrangulate!"
    And I follow "Tag Wrangling"
    
  # create a new canonical freeform from tag wrangling interface
    And I follow "New Tag"
    And I fill in "Name" with "Alternate Universe Pirates"
    And I choose "Freeform"
    And I check "tag_canonical"
    And I press "Create Tag"
  Then I should see "Tag was successfully created"
    And the "tag_canonical" checkbox should be checked
    And the "tag_canonical" checkbox should not be disabled
  
  # create a new non-canonical freeform from tag wrangling interface
  When I follow "New Tag"
    And I fill in "Name" with "Pirates! in Spaaaaace! AU"
    And I choose "Freeform"
    And I press "Create Tag"
  Then I should see "Tag was successfully created"
    And the "tag_canonical" checkbox should not be checked
    And the "tag_canonical" checkbox should not be disabled
    
  # creating a new canonical freeform by synning
  When I fill in "Synonym of" with "Alternate Universe Space Pirates"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should not see "Synonyms"
  When I follow "Alternate Universe Space Pirates"
  Then I should see "Make tag non-canonical and unhook all associations"
    And I should see "Pirates! in Spaaaaace! AU"
    And the "tag_canonical" checkbox should be checked
    And the "tag_canonical" checkbox should be disabled
  
  # creating non-canonical freeforms from work posting
  When I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Torchwood"
    And I fill in "Work Title" with "Silliness"
    And I fill in "Additional Tags" with "Pirate AU, Arrr-verse"
    And I fill in "content" with "And then everyone was kidnapped by an alien bus."
    And I press "Preview"
    And I press "Post"
  Then I should see "Work was successfully posted."
  
  # editing non-canonical freeform in order to syn it to existing canonical merger
  When I follow "Pirate AU"
    And I follow "Edit"
    And I fill in "Synonym of" with "Alternate Universe "
  Then I should find "Alternate Universe Pirates" within ".autocomplete"
  When I fill in "Synonym of" with "Alternate Universe Pirates"
    And I fill in "Fandoms" with "No"
    And I should find "No Fandom" within ".autocomplete"
    And I fill in "Fandoms" with "No Fandom"
    And I press "Save changes"
  Then I should see "Tag was updated"
  
  # adding a non-canonical synonym to a canonical, fandom should be copied
  When I follow "Alternate Universe Pirates"
  Then I should see "No Fandom"
    And I should see "Pirate AU"
    And the "tag_canonical" checkbox should be disabled
  When I fill in "tag_merger_string" with "Arrr"
  Then I should find "Arrr-verse" within ".autocomplete"
  When I fill in "tag_merger_string" with "Arrr-verse"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should see "Arrr-verse"
  When I follow "Arrr-verse"
  Then I should see "No Fandom"
  
  # metatags and subtags, transference thereof to a new canonical
  When I follow "Alternate Universe Pirates"
    And I fill in "MetaTags" with "Alternate Universe"
    And I press "Save changes"
  Then I should see "Tag was updated"
    But I should not see "Alternate Universe" within "fieldset.tags"
  When I follow "New Tag"
    And I fill in "Name" with "Alternate Universe"
    And I check "tag_canonical"
    And I choose "Freeform"
    And I press "Create Tag"
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "SubTags" with "Alternate Universe P"
  Then I should find "Alternate Universe Pirates" within ".autocomplete"
  When I fill in "SubTags" with "Alternate Universe Pirates"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should see "No Fandom"
    And the "tag_canonical" checkbox should be checked
  When I follow "Alternate Universe Pirates"
  Then I should see "Alternate Universe" within "div#parent_MetaTag_associations_to_remove_checkboxes"
  When I edit the tag "Alternate Universe Space Pirates"
    And I fill in "MetaTags" with "Alternate Universe P"
    And I should find "Alternate Universe Pirates" within ".autocomplete"
    And I fill in "MetaTags" with "Alternate Universe Pirates"
    And I press "Save changes"
  Then I should see "Tag was updated"
  When I follow "Alternate Universe Pirates"
  Then I should see "Alternate Universe Space Pirates"
  When I fill in "Synonym of" with "Alternate Universe Pirrrates"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should not see "Alternate Universe Space Pirates"
    And I should not see "Pirate AU"
    And I should not see "Arrr-verse"
  When I follow "Alternate Universe Pirrrates"
  Then I should see "Alternate Universe Space Pirates"
    And I should see "Pirate AU"
    And I should see "Arrr-verse"
    And I should see "Alternate Universe Pirates"

  # trying to syn a non-canonical to another non-canonical
  When I follow "New Tag"
    And I fill in "Name" with "Drabble"
    And I choose "Freeform"
    And I press "Create Tag"
    And I follow "New Tag"
    And I fill in "Name" with "100 words"
    And I choose "Freeform"
    And I press "Create Tag"
    And I fill in "Synonym of" with "Drabble"
    And I press "Save changes"
  Then I should see "Drabble is not a canonical tag. Please make it canonical before adding synonyms to it."

  # trying to syn a non-canonical to a canonical of a different category
  When I fill in "Synonym of" with "No Fandom"
    And I press "Save changes"
  Then I should see "No Fandom is a fandom. Synonyms must belong to the same category."

