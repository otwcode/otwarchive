@users
Feature: User dashboard
  In order to have an archive full of users
  As a humble user
  I want to write some works and see my dashboard
    
  Scenario: Fandoms on user dashboard
  
  Given the following activated users exist
    | login           | password   |
    | bookmarkuser1   | password   |
    | bookmarkuser2   | password   |
  Given the following activated tag wrangler exists
    | login  | password    |
    | Enigel | wrangulate! |
    
  # set up metatag and synonym
    
  When I am logged in as "Enigel" with password "wrangulate!"
    And a fandom exists with name: "Stargate SG-1", canonical: true
    And a fandom exists with name: "Stargatte SG-oops", canonical: false
    And a fandom exists with name: "Stargate Franchise", canonical: true
    And I edit the tag "Stargate SG-1"
    And I fill in "MetaTags" with "Stargate Franchise"
    And I press "Save changes"
  Then I should see "Tag was updated"
  When I edit the tag "Stargatte SG-oops"
    And I fill in "Synonym" with "Stargate SG-1"
    And I press "Save changes"
  Then I should see "Tag was updated"
  
  # view user dashboard - when posting a work with the canonical, metatag and synonym should not be seen
  
  When I log out
  Then I should see "Sorry, you don't have permission to access the page you were trying to reach. Please log in."
    
  When I am logged in as "bookmarkuser1" with password "password"
  Then I should see "Hi, bookmarkuser1!"
  When I go to bookmarkuser2's user page
  Then I should see "There are no works or bookmarks under this name yet"
  When I go to bookmarkuser1's user page
  Then I should see "Dashboard"
    And I should see "You don't have anything posted under this name yet"
    And I should not see "Revenge of the Sith"
    And I should not see "Stargate"
  When I am logged in as "bookmarkuser2" with password "password"
    And I post the work "Revenge of the Sith"
  When I go to the bookmarks page
  Then I should not see "Revenge of the Sith"
  When I go to bookmarkuser2's user page
  Then I should see "Stargate"
    And I should see "SG-1" within "#user-fandoms"
    And I should not see "Stargate Franchise"
    And I should not see "Stargatte SG-oops"
    
  # now using the synonym - canonical should be seen, but metatag still not seen
  
  When I edit the work "Revenge of the Sith"
    And I fill in "Fandoms" with "Stargatte SG-oops"
    And I press "Preview"
    And I press "Update"
  Then I should see "Work was successfully updated"
  When I go to bookmarkuser2's user page
  Then I should see "Stargate"
    And I should see "SG-1" within "#user-fandoms"
    And I should not see "Stargate Franchise"
    And I should not see "Stargatte SG-oops" within "#user-fandoms"
    And I should see "Stargatte SG-oops"
