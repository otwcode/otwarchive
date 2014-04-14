@users @tag_wrangling
Feature: Tag wrangling

  Scenario: Admin can create a tag wrangler using the interface

    Given the following admin exists
      | login       |
      | Zooey       |
      And the following activated user exists
      | login       |
      | dizmo       |
      And I have loaded the "roles" fixture
    When I am logged in as "dizmo"
    Then I should not see "Tag Wrangling" within "#header"
    When I am logged in as an admin
      And I fill in "query" with "dizmo"
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
      And I fill in "Fandoms" with "Stargate SG-1, Star Wars"
      And I fill in "Work Title" with "Revenge of the Sith 2"
      And I fill in "Characters" with "Daniel Jackson, Jack O'Neil"
      And I fill in "Relationships" with "McShep"
      And I fill in "content" with "That could be an amusing crossover."
      And I press "Preview"
      And I press "Post"
      Then I should see "Work was successfully posted."
    
    # mass wrangling
    When I follow "Tag Wrangling" within "#header"
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
    Then I should see "Tag was updated"
      And I should not see "Stargate Atlantis"
      
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

  Scenario: Issue 1701: Sign up for a fandom from the edit fandom page, then from editing a child tag of a fandom
    
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
      And the autocomplete value should be set to "'Allo 'Allo"
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
    Then I should see "Cabin Pressure" in the autocomplete
      And I should see "From Eroica with Love" in the autocomplete
    When I press "Assign"
    Then I should see "Wranglers were successfully assigned"
    When I edit the tag "From Eroica with Love"
    Then I should not see "Sign Up"
      And I should see the tag wrangler listed as an editor of the tag
    When I edit the tag "Cabin Pressure"
    Then I should not see "Sign Up"
      And I should see the tag wrangler listed as an editor of the tag
