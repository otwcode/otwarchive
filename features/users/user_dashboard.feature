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

  Scenario: When a user has more works, series, or bookmarks than the maximum displayed on dashboards (5), the "Recent" listbox for that type of item should contain a link to that user's page for that type of item (e.g. Works (6), Bookmarks (10)). The link should go to the user's works, series, or bookmarks page. That link should not exist for any pseuds belonging to that user until the pseud has 5 or more works/series/bookmarks, and then the pseud's link should go to the works/series/bookmarks page for that pseud.
  
  Given I am logged in as "meatloaf" with password "parad1s3"
    And I post the work "Oldest Work"
    And I post the work "Work 2"
    And I post the work "Work 3"
    And I post the work "Work 4"
    And I post the work "Work 5"
    And I post the work "Newest Work"
  
  # Check the Works link for the user
  When I go to meatloaf's user page
  Then I should see "Recent works"
    And I should see "Newest Work"
    And I should not see "Oldest Work"
    And I should see "Works (6)" within "#user-works"
  When I follow "Works (6)" within "#user-works"
  Then I should see "6 Works by meatloaf"
    And I should see "Oldest Work"
    And I should see "Newest Work"

  # Add works to series
  When I add the work "Oldest Work" to series "Oldest Series"
    And I add the work "Work 2" to series "Series 2"
    And I add the work "Work 3" to series "Series 3"
    And I add the work "Work 4" to series "Series 4"
    And I add the work "Work 5" to series "Series 5"
    And I add the work "Newest Work" to series "Newest Series"

  # Check the Series link for the user
  When I go to meatloaf's user page
  Then I should see "Recent series"
    And I should see "Newest Series" within "#user-series"
    And I should not find "Oldest Series" within "#user-series"
    And I should see "Series (6)" within "#user-series"
  When I follow "Series (6)" within "#user-series"
  Then I should see "meatloaf's Series"
    And I should see "Oldest Series"
    And I should see "Newest Series"
  
  # Create a pseud
  When I create the pseud "gravy"
  Then I should see "You don't have anything posted under this name yet."
  
  # Create a work and series for the pseud and make sure the user's work count doesn't carry over
  When I add the work "Pseud's Work 1" to series "Pseud Series A" as "gravy"
  
  When I go to meatloaf's user page
    And I follow "gravy" within ".pseud .expandable li"
  Then I should see "Recent works"
    And I should see "Pseud's Work 1"
    And I should not see "Works (" within "#user-works"
  
  # Create 6 more works and series for the pseud
  When I add the work "Pseud's Work 2" to series "Pseud Series B" as "gravy"
    And I add the work "Pseud's Work 3" to series "Pseud Series C" as "gravy"
    And I add the work "Pseud's Work 4" to series "Pseud Series D" as "gravy"
    And I add the work "Pseud's Work 5" to series "Pseud Series E" as "gravy"
    And I add the work "Pseud's Work 6" to series "Pseud Series F" as "gravy"
    And I add the work "Pseud's Work 7" to series "Pseud Series G" as "gravy"
  
  # Check the Works link for the pseud
  When I go to meatloaf's user page
    And I follow "gravy" within ".pseud .expandable li"
  Then I should see "Recent works"
    And I should see "Works (7)" within "#user-works"
    And I should see the most recent work for pseud "gravy"
    And I should not see the oldest work for pseud "gravy"
  When I follow "Works (7)" within "#user-works"
  Then I should see "7 Works by gravy (meatloaf)"
    And I should see the most recent work for pseud "gravy"
    And I should see the oldest work for pseud "gravy"
    
  # Check the Series link for the pseud
  When I follow "gravy" within ".pseud .expandable li"
  Then I should see "Recent series"
    And I should see the most recent series for pseud "gravy"
    And I should not see the oldest series for pseud "gravy"
    And I should see "Series (7)" within "#user-series"
  When I follow "Series (7)" within "#user-series"
  Then I should see the most recent series for pseud "gravy"
    And I should see the oldest series for pseud "gravy"

  # Create 7 bookmarks for the user
  When I bookmark the work "Pseud's Work 1"
    And I bookmark the work "Pseud's Work 2"
    And I bookmark the work "Pseud's Work 3"
    And I bookmark the work "Pseud's Work 4"
    And I bookmark the work "Pseud's Work 5"
    And I bookmark the work "Pseud's Work 6"
    And I bookmark the work "Pseud's Work 7"

  # Check the Bookmarks link for the user
  When I go to meatloaf's user page
  Then I should see "Recent bookmarks"
    And I should see "Bookmarks (7)" within "#user-bookmarks"
  When I follow "Bookmarks (7)" within "#user-bookmarks"
  Then I should see "7 Bookmarks by meatloaf"

  # Create a bookmark for the pseud and make sure the user's bookmark count doesn't carry over
  When I bookmark the work "Oldest Work" as "gravy"
    And I follow "meatloaf"
    And I follow "gravy" within ".pseud .expandable li"
  Then I should see "Recent bookmarks"
    And I should see "Oldest Work"
    And I should not see "Bookmarks (7)" within "#user-bookmarks"

  # Create 5 more bookmarks for the pseud
  When I bookmark the work "Work 2" as "gravy"
    And I bookmark the work "Work 3" as "gravy"
    And I bookmark the work "Work 4" as "gravy"
    And I bookmark the work "Work 5" as "gravy"
    And I bookmark the work "Newest Work" as "gravy"

  # Check the Bookmarks link for the pseud
  When I go to meatloaf's user page
    And I follow "gravy" within ".pseud .expandable li"
  Then I should see "Recent bookmarks"
    And I should see "Bookmarks (6)" within "#user-bookmarks"
