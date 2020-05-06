@users @tag_wrangling
Feature: Tag wrangling

  Scenario: Admin can create a tag wrangler using the interface

    Given I have loaded the "roles" fixture
    When I am logged in as "dizmo"
    Then I should not see "Tag Wrangling" within "#header"
    When I am logged in as superadmin
      And I go to the manage users page
      And I fill in "Name" with "dizmo"
      And I press "Find"
    Then I should see "dizmo" within "#admin_users_table"    
    # admin making user tag wrangler
    When I check "user_roles_1"
      And I press "Update"
    Then I should see "User was successfully updated"
    # accessing wrangling pages
    When I am logged in as "dizmo"
      And I follow "Tag Wrangling" within "#header"
    Then I should see "Wrangling Home"
    # no access otherwise
    When I log out
    Then I should see "Sorry, you don't have permission"

  Scenario: Log in as a tag wrangler and see wrangler pages.
        Make a new fandom canonical and wrangle it to a medium.
        Make a new character canonical and wrangle them to a fandom.
        Make a new synonym of a character and check that the fandom transfers.
    Given I have no users
      And I have no tags
      And basic tags
      And I have loaded the "roles" fixture
      And the following activated tag wrangler exists
      | login       |
      | dizmo       |
      And a media exists with name: "TV Shows", canonical: true
    When I am logged in as "dizmo"
    When I follow "Tag Wrangling" within "#header"
    Then I should see "Wrangling Home"
      And I should not see "Stargate SG-1"
    When I follow "Wranglers"
    Then I should see "Tag Wrangling Assignments"
      And I should not see "Stargate SG-1"
    When I follow "Wrangling Tools"
    Then I should see "Fandoms by media (1)"
    When I follow "Fandoms by media (1)"
    Then I should see "Mass Wrangle New/Unwrangled Tags"
      And I should not see "Stargate SG-1"
    When I go to the new work page
      And I select "Not Rated" from "Rating"
      And I check "No Archive Warnings Apply"
      And I select "English" from "Choose a language"
      And I fill in "Fandoms" with "Stargate SG-1, Star Wars"
      And I fill in "Work Title" with "Revenge of the Sith 2"
      And I fill in "Characters" with "Daniel Jackson, Jack O'Neil"
      And I fill in "Relationships" with "McShep"
      And I fill in "content" with "That could be an amusing crossover."
      And I press "Preview"
      And I press "Post"
      And The periodic tag count task is run
      Then I should see "Work was successfully posted."
    
    # mass wrangling
    When I flush the wrangling sidebar caches
      And I follow "Tag Wrangling" within "#header"
    Then I should see "Wrangling Home"
      And I should see "Wrangling Tools"
      And I should see "Fandoms by media (3)"
      And I should see "Characters by fandom (2)"
      And I should see "Relationships by fandom (1)"
    When I follow "Fandoms by media (3)"
    Then I should see "Mass Wrangle New/Unwrangled Tags"
      And I should see "Stargate SG-1"
    When I view the work "Revenge of the Sith 2"
    Then I should see "Stargate SG-1"
    
    # making a fandom canonical and assigning media to it
    When I follow "Stargate SG-1"
    Then I should see "Edit"
    When I follow "Edit" within ".header"
    Then I should see "Edit Stargate SG-1 Tag"
    When I check "tag_canonical"
      And I fill in "tag_media_string" with "TV Shows"
      And I press "Save changes"
    Then I should see "Tag was updated"
    When I follow "Tag Wrangling" within "#header"
    Then I should see "Wrangling Home"
      And I should not see "Stargate SG-1"
    When I follow "Wranglers"
    Then I should see "Tag Wrangling Assignments"
      And I should see "Stargate SG-1"
      
    # assign wrangler to a fandom
    When I fill in "tag_fandom_string" with "Stargate SG-1"
      And I press "Assign"
      And I follow "Wrangling Home"
    Then I should see "Stargate SG-1"
    When I follow "Wranglers"
    Then I should see "Stargate SG-1"
      And I should see "dizmo" within "ul.wranglers"
    When I follow "Wrangling Tools"
      And I follow "Characters by fandom (2)"
    Then I should see "Daniel Jackson"
      And I should see "Jack O'Neil"
     
    # making a character tag canonical and assigning it a fandom
    When I view the tag "Daniel Jackson"
      And I follow "Edit" within ".header"
    Then I should see "Edit Daniel Jackson Tag"
    When I check "tag_canonical"
      And I fill in "Fandoms" with "Stargate SG-1"
      And I press "Save changes"
    Then I should see "Tag was updated"
    
    # assigning a fandom to a non-canonical character
    When I view the tag "Jack O'Neil"
      And I follow "Edit" within ".header"
      And I fill in "Fandoms" with "Stargate SG-1"
      And I press "Save changes"
    Then I should see "Tag was updated"
    
    # assigning (and creating) a canonical merger to a non-canonical character
    When I fill in "Synonym of" with "Jack O'Neill"
      And I press "Save changes"
      And I follow "Jack O'Neill"
    Then I should see "Stargate SG-1"
    When I view the tag "Stargate SG-1"
    Then I should see "Daniel Jackson"
      And I should see "Jack O'Neil"
      And I should see "Jack O'Neill"
      
    # creating a new non-canonical fandom tag
    When I follow "Tag Wrangling" within "#header"
      And I follow "New Tag"
      And I fill in "Name" with "Stargate Atlantis"
      And I choose "Fandom"
      And I press "Create Tag"
    Then I should see "Tag was successfully created"
    
    # creating a new canonical character
    When I follow "New Tag"
      And I fill in "Name" with "John Sheppard"
      And I choose "Character"
      And I check "Canonical"
      And I press "Create Tag"
    Then I should see "Tag was successfully created"
    
    # trying to assign a non-canonical fandom to a character
    When I fill in "Fandoms" with "Stargate Atlantis"
      And I press "Save changes"
    Then I should see "Cannot add association to 'Stargate Atlantis':"
      And I should see "Parent tag is not canonical."
      And I should not see "Stargate Atlantis" within "form"
      
    # making a fandom tag canonical, then assigning it to a character
    When I view the tag "Stargate Atlantis"
      And I follow "Edit" within ".header"
      And I check "tag_canonical"
      And I press "Save changes"
      And I view the tag "John Sheppard"
      And I follow "Edit" within ".header"
      And I fill in "Fandoms" with "Stargate Atlantis"
      And I press "Save changes"
    Then I should see "Tag was updated"
      And I should see "Stargate Atlantis"
    When I follow "New Tag"
      And I fill in "Name" with "Rodney McKay"
      And I choose "Character"
      And I check "Canonical"
      And I press "Create Tag"
    Then I should see "Tag was successfully created"
    When I fill in "Fandoms" with "Stargate Atlantis"
      And I press "Save changes"
    Then I should see "Tag was updated"
    
    # assigning a fandom to a non-canonical relationship tag
    When I view the tag "McShep"
      And I follow "Edit" within ".header"
      And I fill in "Fandoms" with "Stargate Atlantis"
      And I press "Save changes"
    Then I should see "Tag was updated"
    
    # assigning (and creating) a canonical merger to a non-canonical relationship
    When I fill in "Synonym of" with "Rodney McKay/John Sheppard"
      And I press "Save changes"
      And I follow "Rodney McKay/John Sheppard"
    Then I should see "Stargate Atlantis"
  
    # assigning characters to a canonical relationship
    When I fill in "Characters" with "Rodney McKay, John Sheppard"
      And I press "Save changes"
    Then I should see "Tag was updated"
      And I should see "Stargate Atlantis"

    # post a work to create new unwrangled and unwrangleable tags in the fandom
    When I post the work "Test Work" with fandom "Stargate SG-1" with character "Samantha Carter" with second character "Anubis Arc"
      And I edit the tag "Anubis Arc"
      And I check "Unwrangleable"
      And I fill in "Fandoms" with "Stargate SG-1"
      And I press "Save changes"
      # Make sure that the indices are up-to-date:
      And all indexing jobs have been run
    Then I should see "Tag was updated"

    # check sidebar links and pages for wrangling within a fandom
    When I am on my wrangling page
      And I follow "Stargate SG-1"
    Then I should see "Wrangle Tags for Stargate SG-1"
    When I follow "Characters (4)"
    Then I should see "Wrangle Tags for Stargate SG-1"
      And I should see "Showing All Character Tags"
      And I should see "Daniel Jackson"
      And I should see "Jack O'Neil"
      And I should see "Anubis Arc"
      But I should not see "Samantha Carter"
    When I follow "Canonical"
    Then I should see "Showing Canonical Character Tags"
      And I should see "Daniel Jackson"
      And I should see "Jack O'Neill"
      But I should not see "Samantha Carter"
      And I should not see "Anubis Arc"
      # This would fail because "Jack O'Neil" is in "Jack O'Neill"
      # But I should not see "Jack O'Neil"
    When I follow "Synonymous"
    Then I should see "Showing Synonymous Character Tags"
      And I should see "Jack O'Neil"
      # It will be in a td in the tbody, whereas "Jack O'Neil" is in a th
      But I should not see "Jack O'Neill" within "tbody th"
      And I should not see "Daniel Jackson"
      And I should not see "Samantha Carter"
      And I should not see "Anubis Arc"
    When I follow "Unwrangled"
    Then I should see "Showing Unwrangled Character Tags"
      And I should see "Samantha Carter"
      And I should not see "Jack O'Neill"
      And I should not see "Daniel Jackson"
      And I should not see "Anubis Arc"
    When I follow "Unwrangleable"
    Then I should see "Showing Unwrangleable Character Tags"
      And I should see "Anubis Arc"
      And I should not see "Samantha Carter"
      And I should not see "Jack O'Neill"
      And I should not see "Daniel Jackson"
    When I follow "Relationships (0)"
    Then I should see "Wrangle Tags for Stargate SG-1"
      And I should see "Showing All Relationship Tags"
    When I follow "Freeforms (0)"
    Then I should see "Wrangle Tags for Stargate SG-1"
      And I should see "Showing All Freeform Tags"
    When I follow "SubTags (0)"
    Then I should see "Wrangle Tags for Stargate SG-1"
      And I should see "Showing All Sub Tag Tags"
    When I follow "Mergers (0)"
    Then I should see "Wrangle Tags for Stargate SG-1"
      And I should see "Showing All Merger Tags"

  Scenario: Wrangler has option to troubleshoot a work

    Given the work "Indexing Issues"
      And I am logged in as a tag wrangler
     When I view the work "Indexing Issues"
     Then I should see "Troubleshoot"

  @javascript
  Scenario: AO3-1698 Sign up for a fandom from the edit fandom page,
    then from editing a child tag of a fandom

    Given a canonical fandom "'Allo 'Allo"
      And a canonical fandom "From Eroica with Love"
      And a canonical fandom "Cabin Pressure"
      And a noncanonical relationship "Dorian/Martin"

    # I want to sign up from the edit page of an unassigned fandom
    When I am logged in as a tag wrangler
      And I edit the tag "'Allo 'Allo"
    Then I should see "Sign Up"
    When I follow "Sign Up"
    Then I should see "Assign fandoms to yourself"
      And I should see "'Allo 'Allo" in the "tag_fandom_string" input
    When I press "Assign"
    Then I should see "Wranglers were successfully assigned"
    When I edit the tag "'Allo 'Allo"
    Then I should not see "Sign Up"
      And I should see the tag wrangler listed as an editor of the tag

    # I want to sign up from the edit page of a relationship that belongs to two unassigned fandoms
    When I edit the tag "Dorian/Martin"
    Then I should not see "Sign Up"
    When I fill in "Fandoms" with "From Eroica with Love, Cabin Pressure"
      And I press "Save changes"
    Then I should see "Tag was updated"
    When I follow "Sign Up"
      And I choose "Cabin Pressure" from the "Enter as many fandoms as you like." autocomplete
      And I choose "From Eroica with Love" from the "Enter as many fandoms as you like." autocomplete
      And I press "Assign"
    Then I should see "Wranglers were successfully assigned"
    When I edit the tag "From Eroica with Love"
    Then I should not see "Sign Up"
      And I should see the tag wrangler listed as an editor of the tag
    When I edit the tag "Cabin Pressure"
    Then I should not see "Sign Up"
      And I should see the tag wrangler listed as an editor of the tag

  Scenario: A user can not see the troubleshoot button on a tag page

    Given a canonical fandom "Cowboy Bebop"
      And I am logged in as a random user
    When I view the tag "Cowboy Bebop"
    Then I should not see "Troubleshoot"

  Scenario: A tag wrangler can see the troubleshoot button on a tag page

    Given a canonical fandom "Cowboy Bebop"
      And the tag wrangler "lain" with password "lainnial" is wrangler of "Cowboy Bebop"
    When I view the tag "Cowboy Bebop"
    Then I should see "Troubleshoot"

  Scenario: An admin can see the troubleshoot button on a tag page

    Given a canonical fandom "Cowboy Bebop"
      And I am logged in as an admin
    When I view the tag "Cowboy Bebop"
    Then I should see "Troubleshoot"

  Scenario: Can simultaneously add a grandparent metatag as a direct metatag and remove the parent metatag
    Given a canonical fandom "Grandparent"
      And a canonical fandom "Parent"
      And a canonical fandom "Child"
      And "Grandparent" is a metatag of the fandom "Parent"
      And "Parent" is a metatag of the fandom "Child"
      And I am logged in as a random user
      And I post the work "Oldest" with fandom "Grandparent"
      And I post the work "Middle" with fandom "Parent"
      And I post the work "Youngest" with fandom "Child"
      And I am logged in as a tag wrangler

    When I edit the tag "Child"
      And I check the 1st checkbox with id matching "MetaTag"
      And I fill in "tag_meta_tag_string" with "Grandparent"
      And I press "Save changes"
    Then I should see "Tag was updated"
      And I should see "Grandparent" within "#parent_MetaTag_associations_to_remove_checkboxes"
      But I should not see "Parent" within "#parent_MetaTag_associations_to_remove_checkboxes"

    When I view the tag "Child"
    Then I should see "Grandparent" within ".meta"
      But I should not see "Parent" within ".meta"

    When I go to the works tagged "Grandparent"
    Then I should see "Oldest"
      And I should see "Middle"
      And I should see "Youngest"

    When I go to the works tagged "Parent"
    Then I should see "Middle"
      But I should not see "Oldest"
      And I should not see "Youngest"

    When I go to the works tagged "Child"
    Then I should see "Youngest"
      But I should not see "Oldest"
      And I should not see "Middle"
