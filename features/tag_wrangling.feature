@users @tag_wrangling
Feature: Tag wrangling

  Scenario: Log in as a tag wrangler and see wrangler pages.
        Make a new fandom canonical and wrangle it to a medium.
        Make a new character canonical and wrangle them to a fandom.
        Make a new synonym of a character and check that the fandom transfers.
    Given I have no users
      And I have no tags
      And basic tags
      And the following admin exists
      | login       | password |
      | Zooey       | secret   |
      And the following activated user exists
      | login       | password      |
      | dizmo       | wrangulator   |
      And a media exists with name: "TV Shows", canonical: true
    When I am logged in as "dizmo" with password "wrangulator"
    Then I should not see "Tag Wrangling"
    When I follow "Log out"
      And I go to the admin_login page
      And I fill in "admin_session_login" with "Zooey"
      And I fill in "admin_session_password" with "secret"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"
    When I fill in "query" with "dizmo"
      And I press "Find"
    Then I should see "dizmo" within "#admin_users_table"
    
    # admin making user tag wrangler
    When I check "user_tag_wrangler"
      And I press "Update"
    Then I should see "User was successfully updated"
    When I follow "Log out"
    
    # accessing wrangling pages
      And I am logged in as "dizmo" with password "wrangulator"
    Then I should see "Hi, dizmo!"
    When I follow "Tag Wrangling"
    Then I should see "Wrangling Home"
      And I should not see "Stargate SG-1"
    When I follow "Wranglers"
    Then I should see "Tag Wrangling Assignments"
      And I should not see "Stargate SG-1"
    When I follow "Mass Wrangling"
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
    When I follow "Tag Wrangling"
    Then I should see "Wrangling Home"
      And I should see "Mass Wrangling"
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
      And I fill in "Medias" with "TV Shows"
      And I press "Save changes"
    Then I should see "Tag was updated"
    When I follow "Tag Wrangling"
    Then I should see "Wrangling Home"
      And I should not see "Stargate SG-1"
    When I follow "Wranglers"
    Then I should see "Tag Wrangling Assignments"
      And I should see "Stargate SG-1"
      And I should not see "dizmo" within ".wranglers"
      
    # assign wrangler to a fandom
    When I fill in "tag_fandom_string" with "Stargate SG-1"
      And I press "Assign"
      And I follow "Wrangling Home"
    Then I should see "Stargate SG-1"
    When I follow "Wranglers"
    Then I should see "Stargate SG-1"
      And I should see "dizmo" within ".wranglers"
    When I follow "Mass Wrangling"
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
    When I follow "Tag Wrangling"
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
    
    Given the following activated tag wrangler exists
      | login  | password    |
      | Enigel | wrangulate |
      And a fandom exists with name: "'Allo 'Allo", canonical: true
      And a fandom exists with name: "From Eroica with Love", canonical: true
      And a fandom exists with name: "Cabin Pressure", canonical: true
      And a relationship exists with name: "Dorian/Martin", canonical: false
    
    # I want to sign up from the edit page of an unassigned fandom
    When I am logged in as "Enigel" with password "wrangulate"
      And I edit the tag "'Allo 'Allo"
    Then I should see "Sign Up"
    When I follow "Sign Up"
    Then I should see "Assign fandoms to yourself"
      And I should see "'Allo 'Allo" within "#tag_fandom_string"
    When I press "Assign"
    Then I should see "Wranglers were successfully assigned"
    When I edit the tag "'Allo 'Allo"
    Then I should not see "Sign Up"
      And I should see "Enigel" within ".tag_edit"
    
    # I want to sign up from the edit page of a relationship that belongs to two unassigned fandoms
    When I edit the tag "Dorian/Martin"
    Then I should not see "Sign Up"
    When I fill in "Fandoms" with "From Eroica with Love, Cabin Pressure"
      And I press "Save changes"
    Then I should see "Tag was updated"
    When I follow "Sign Up"
    Then I should see "Cabin Pressure, From Eroica with Love" within "#tag_fandom_string"
    When I press "Assign"
    Then I should see "Wranglers were successfully assigned"
    When I edit the tag "From Eroica with Love"
    Then I should not see "Sign Up"
      And I should see "Enigel" within ".tag_edit"
    When I edit the tag "Cabin Pressure"
    Then I should not see "Sign Up"
      And I should see "Enigel" within ".tag_edit"
