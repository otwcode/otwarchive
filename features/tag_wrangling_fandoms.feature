@tags @users @tag_wrangling

Feature: Tag Wrangling - Fandoms

Scenario: fandoms wrangling - syns, mergers, autocompletes, metatags

  Given the following activated tag wrangler exists
    | login  | password    |
    | Enigel | wrangulate! |
    And basic tags
    And a media exists with name: "TV Shows", canonical: true
    And a character exists with name: "Neal Caffrey", canonical: true
    And I am logged in as "Enigel" with password "wrangulate!"
    And I follow "Tag Wrangling"
    
  # create a new canonical fandom from tag wrangling interface
    And I follow "New Tag"
    And I fill in "Name" with "Stargate SG-1"
    And I choose "Fandom"
    And I check "tag_canonical"
    And I press "Create Tag"
  Then I should see "Tag was successfully created"
    And the "tag_canonical" checkbox should be checked
    And the "tag_canonical" checkbox should not be disabled
  
  # create a new non-canonical fandom from tag wrangling interface
  When I follow "New Tag"
    And I fill in "Name" with "SGA"
    And I choose "Fandom"
    And I press "Create Tag"
  Then I should see "Tag was successfully created"
    And the "tag_canonical" checkbox should not be checked
    And the "tag_canonical" checkbox should not be disabled
    
  # creating a new canonical fandom by synning
  When I fill in "Synonym of" with "Stargate Atlantis"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should not see "Synonyms"
  When I follow "Stargate Atlantis"
  Then I should see "Make tag non-canonical and unhook all associations"
    And I should see "SGA"
    And the "tag_canonical" checkbox should be checked
    And the "tag_canonical" checkbox should be disabled
  
  # creating non-canonical fandoms from work posting
  When I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "SG1, the whole Stargate franchise, Stargates SG-1"
    And I fill in "Work Title" with "Silliness"
    And I fill in "content" with "And then everyone was kidnapped by an alien bus."
    And I press "Preview"
    And I press "Post"
  Then I should see "Work was successfully posted."
  
  # editing non-canonical fandom in order to syn it to existing canonical merger
  When I follow "SG1"
    And I follow "Edit"
    And I fill in "Synonym of" with "Stargate"
  Then I should find "Stargate Atlantis" within ".auto_complete"
    And I should find "Stargate SG-1" within ".auto_complete"
  When I fill in "Synonym of" with "Stargate SG-1"
    And I fill in "Medias" with "TV"
    And I should find "TV Shows" within ".auto_complete"
    And I fill in "Medias" with "TV Shows"
    And I press "Save changes"
  Then I should see "Tag was updated"
  
  # adding a non-canonical synonym to a canonical, fandom should be copied
  When I follow "Stargate SG-1"
  Then I should see "TV Shows"
    And I should see "SG-1"
    And the "tag_canonical" checkbox should be disabled
  When I fill in "Synonyms" with "Stargate"
  Then I should find "Stargates SG-1" within ".auto_complete"
    And I should find "the whole Stargate franchise" within ".auto_complete"
    And I should not find "Stargate SG-1" within ".auto_complete"
  When I fill in "Synonyms" with "Stargates SG-1"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should see "Stargates SG-1"
  When I follow "Stargates SG-1"
  Then I should see "TV Shows"
  
  # metatags and subtags, transference thereof to a new canonical
  When I edit the tag "Stargate Atlantis"
    And I fill in "MetaTags" with "Stargate Franchise"
    And I press "Save changes"
  Then I should see "Tag was updated"
    But I should not see "Stargate Franchise" within "ul.tags"
  When I follow "New Tag"
    And I fill in "Name" with "Stargate Franchise"
    And I check "tag_canonical"
    And I choose "Fandom"
    And I press "Create Tag"
    And I fill in "Medias" with "TV Shows"
    And I fill in "SubTags" with "Stargate Atlantis"
  Then I should find "Stargate Atlantis" within ".auto_complete"
  When I fill in "SubTags" with "Stargate Atlantis"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should see "TV Shows"
    And the "tag_canonical" checkbox should be checked
  When I follow "Stargate Atlantis"
  Then I should see "Stargate Franchise" within "ul.tags"
  When I edit the tag "Stargate SG-1"
    And I fill in "MetaTags" with "Stargate Franchise"
    And I should find "Stargate Franchise" within ".auto_complete"
    And I fill in "MetaTags" with "Stargate Franchise"
    And I press "Save changes"
  Then I should see "Tag was updated"
  When I follow "New Tag"
    And I fill in "Name" with "Stargate SG-1: Ark of Truth"
    And I check "tag_canonical"
    And I choose "Fandom"
    And I press "Create Tag"
    And I fill in "MetaTags" with "Stargate SG-1"
    And I press "Save changes"
    And I follow "Stargate SG-1"
  Then I should see "Stargate SG-1: Ark of Truth" within "ul.tags"
    And I should see "Stargate Franchise" within "ul.tags"
  When I fill in "Synonym of" with "Stargate SG-1: Greatest Show in the Universe"
    And I press "Save changes"
  Then I should see "Tag was updated"
    And I should not see "Stargate SG-1: Ark of Truth"
    And I should not see "Stargates SG-1"
    And I should not see "SG1"
    And I should not see "Stargate Franchise"
  When I follow "Stargate SG-1: Greatest Show in the Universe"
  Then I should see "Stargate SG-1: Ark of Truth"
    And I should see "Stargates SG-1"
    And I should see "SG1"
    And I should see "Stargate Franchise"
    
  # trying to syn a non-canonical to another non-canonical
  When I follow "New Tag"
    And I fill in "Name" with "White Collar"
    And I choose "Fandom"
    And I press "Create Tag"
    And I follow "New Tag"
    And I fill in "Name" with "WhiCo"
    And I choose "Fandom"
    And I press "Create Tag"
    And I fill in "Synonym of" with "White Collar"
    And I press "Save changes"
  Then I should see "White Collar is not a canonical tag. Please make it canonical before adding synonyms to it."

  # trying to syn a non-canonical to a canonical of a different category
  When I fill in "Synonym of" with "Neal Caffrey"
    And I press "Save changes"
  Then I should see "Neal Caffrey is a character. Synonyms must belong to the same category."
