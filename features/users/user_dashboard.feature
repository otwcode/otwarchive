@users
Feature: User dashboard
  In order to have an archive full of users
  As a humble user
  I want to write some works and see my dashboard
  
  Scenario: If I have no creations my dashboard is empty
  Given I am logged in as "first_user"
    And I go to my user page
  Then I should see "You don't have anything posted under this name yet"
  Given I am logged in as "second_user"
    And I go to first_user's user page
  Then I should see "There are no works or bookmarks under this name yet"
  When I am logged in as "first_user"
    And I post the work "First Work"
    And I go to my user page
  Then I should not see "You don't have anything posted under this name yet"
    And I should see "First Work"
  When I am logged in as "second_user"
    And I go to first_user's user page
  Then I should not see "There are no works or bookmarks under this name yet"
    And I should see "First Work"
    
  Scenario: Canonical synonym fandoms should be used in the fandoms listing but actual tags should be displayed on the work blurb
  Given I am logged in as a tag wrangler
    # set up metatag and synonym
    And a fandom exists with name: "Stargate SG-1", canonical: true
    And a fandom exists with name: "Stargatte SG-oops", canonical: false
    And a fandom exists with name: "Stargate Franchise", canonical: true
    And I edit the tag "Stargate SG-1"
    And I fill in "MetaTags" with "Stargate Franchise"
    And I press "Save changes"
    And I edit the tag "Stargatte SG-oops"
    And I fill in "Synonym" with "Stargate SG-1"
    And I press "Save changes"  
  # view user dashboard - when posting a work with the canonical, metatag and synonym should not be seen
  When I am logged in as "first_user"
    And I post the work "Revenge of the Sith" with fandom "Stargate SG-1"
    And I go to my user page
  Then I should see "Stargate SG-1" within "#user-fandoms"
    And I should not see "Stargate Franchise"
    And I should not see "Stargatte SG-oops"
  # now using the synonym - canonical should be seen, but metatag still not seen
  When I edit the work "Revenge of the Sith"
    And I fill in "Fandoms" with "Stargatte SG-oops"
    And I press "Preview"
    And I press "Update"
  Then I should see "Work was successfully updated"
  When I go to my user page
  Then I should see "Stargate SG-1" within "#user-fandoms"
    And I should not see "Stargate Franchise"
    And I should not see "Stargatte SG-oops" within "#user-fandoms"
    And I should see "Stargatte SG-oops" within "#user-works"

  Scenario: The user dashboard should list up to five of the user's works and link to more
  Given I am logged in as "meatloaf"
    And I post the works "Oldest Work, Work 2, Work 3, Work 4, Work 5"
  When I go to meatloaf's user page
  Then I should see "Recent works"
    And I should see "Oldest Work"
    And I should see "Work 5"
    And I should not see "Works (5)" within "#user-works"
  When I post the work "Newest Work"
    And I go to meatloaf's user page
  Then I should see "Newest Work"
    And I should not see "Oldest Work"
  When I follow "Works (6)" within "#user-works"
  Then I should see "6 Works by meatloaf"
    And I should see "Oldest Work"
    And I should see "Newest Work"

  Scenario: The user dashboard should list up to five of the user's series and link to more
  Given I am logged in as "meatloaf"
    And I post the work "My Work"
  When I add the work "My Work" to the series "Oldest Series"
    And I add the work "My Work" to the series "Series 2"
    And I add the work "My Work" to the series "Series 3"
    And I add the work "My Work" to the series "Series 4"
    And I add the work "My Work" to the series "Series 5"
  When I go to meatloaf's user page
  Then I should see "Recent series"
    And I should see "Oldest Series" within "#user-series"
  When I add the work "My Work" to the series "Newest Series"
    And I go to meatloaf's user page
  Then I should see "Newest Series" within "#user-series"
    And I should not see "Oldest Series" within "#user-series"
  When I follow "Series (6)" within "#user-series"
  Then I should see "meatloaf's Series"
    And I should see "Oldest Series"
    And I should see "Newest Series"

  Scenario: The user dashboard should list up to five of the user's bookmarks and link to more
  Given I am logged in as "fruitpie"
    And I post the works "Work 1, Work 2, Work 3, Work 4, Work 5, Work 6"
  When I am logged in as "meatloaf"
    And I bookmark the works "Work 1, Work 2, Work 3, Work 4, Work 5"
  When I go to meatloaf's user page
  Then I should see "Recent bookmarks"
    And I should see "Work 1" within "#user-bookmarks"
  When I bookmark the work "Work 6"
    And I go to meatloaf's user page
  Then I should see "Work 6" within "#user-bookmarks"
    And I should not see "Work 1" within "#user-bookmarks"
  When I follow "Bookmarks (6)" within "#user-bookmarks"
  Then I should see "6 Bookmarks by meatloaf"
    And I should see "Work 1"
    And I should see "Work 6"
    
  Scenario: The dashboard for a specific pseud should only list the creations owned by that pseud 
  Given I am logged in as "meatloaf"
    And I post the works "Oldest Work, Work 2, Work 3, Work 4, Work 5"
    And I add the work "Oldest Work" to series "Oldest Series"
    And I bookmark the work "Oldest Work"
  When I add the work "Pseud's Work 1" to series "Pseud Series A" as "gravy"
    And I bookmark the work "Work 5" as "gravy"
    And I go to meatloaf's user page
    And I follow "gravy" within ".pseud .expandable li"
  Then I should see "Recent works"
    And I should see "Pseud's Work 1"
    And I should not see "Works (" within "#user-works"
    And I should not see "Oldest Work" within "#user-works"
  Then I should see "Recent series"
    And I should see "Pseud Series A" within "#user-series"
    And I should not see "Oldest Series"
  Then I should see "Recent bookmarks"
    And I should see "Work 5" within "#user-bookmarks"
