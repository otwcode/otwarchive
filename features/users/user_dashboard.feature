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
  
  Given I am logged in as "testy" with password "t3st1ng"
    And I add the work "Oldest Work" to series "Oldest Series"
    And I add the work "Work 2" to series "Series 2"
    And I add the work "Work 3" to series "Series 3"
    And I add the work "Work 4" to series "Series 4"
    And I add the work "Work 5" to series "Series 5"
    And I add the work "Newest Work" to series "Newest Series"
  
  # Check the Works link for the user
  When I go to testy's user page
  Then I should see "Recent works"
    And I should see "Newest Work"
    And I should not see "Oldest Work"
    And I should see "Works (6)" within "#user-works"
  When I follow "Works (6)" within "#user-works"
  Then I should see "6 Works by testy"
    And I should see "Oldest Work"
    And I should see "Newest Work"
  
  # Check the Series link for the user
  When I go to testy's user page
  Then I should see "Recent series"
    And I should see "Newest Series"
    And I should not see "Oldest Series"
    And I should see "Series (6)" within "#user-series"
  When I follow "Series (6)" within "#user-series"
  Then I should see "testy's Series"
    And I should see "Oldest Series"
    And I should see "Newest Series"
  
  # Create a pseud
  When "testy" creates the pseud "tester"
  Then I should see "You don't have anything posted under this name yet."
  
  # Create a work and series for the pseud and make sure the user's work count doesn't carry over
  When I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Testing"
    And I fill in "Work Title" with "Pseud's Work 1"
    And I select "tester" from "work_author_attributes_ids_"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "Pseud Series A"
    And I fill in "content" with "This is a work for the pseud."
    And I press "Post Without Preview"
  Then I should see "Work was successfully posted."
  When I go to testy's user page
    And I follow "tester" within ".pseud .expandable li"
  Then I should see "Recent works"
    And I should see "Pseud's Work 1"
    And I should not see "Works (" within "#user-works"
  
  # Create 6 more works and series for the pseud
  When I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Testing"
    And I fill in "Work Title" with "Pseud's Work 2"
    And I select "tester" from "work_author_attributes_ids_"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "Pseud Series B"
    And I fill in "content" with "This is a work for the pseud."
    And I press "Post Without Preview"
  Then I should see "Work was successfully posted."
  When I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Testing"
    And I fill in "Work Title" with "Pseud's Work 3"
    And I select "tester" from "work_author_attributes_ids_"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "Pseud Series C"
    And I fill in "content" with "This is a work for the pseud."
    And I press "Post Without Preview"
  Then I should see "Work was successfully posted."
  When I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Testing"
    And I fill in "Work Title" with "Pseud's Work 4"
    And I select "tester" from "work_author_attributes_ids_"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "Pseud Series D"
    And I fill in "content" with "This is a work for the pseud."
    And I press "Post Without Preview"
  Then I should see "Work was successfully posted."
  When I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Testing"
    And I fill in "Work Title" with "Pseud's Work 5"
    And I select "tester" from "work_author_attributes_ids_"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "Pseud Series E"
    And I fill in "content" with "This is a work for the pseud."
    And I press "Post Without Preview"
  Then I should see "Work was successfully posted."
  When I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Testing"
    And I fill in "Work Title" with "Pseud's Work 6"
    And I select "tester" from "work_author_attributes_ids_"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "Pseud Series F"
    And I fill in "content" with "This is a work for the pseud."
    And I press "Post Without Preview"
  Then I should see "Work was successfully posted."
  When I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Testing"
    And I fill in "Work Title" with "Pseud's Work 7"
    And I select "tester" from "work_author_attributes_ids_"
    And I fill in "content" with "This is a work for the pseud."
    And I press "Post Without Preview"
  Then I should see "Work was successfully posted."
  
  # Check the Works link for the pseud
  When I go to testy's user page
    And I follow "tester" within ".pseud .expandable li"
  Then I should see "Recent works"
    And I should see "Pseud's Work 7"
    And I should not see "Pseud's Work 1"
    And I should see "Works (7)" within "#user-works"
  When I follow "Works (7)" within "#user-works"
  Then I should see "7 Works by tester (testy)"
    And I should see "Pseud's Work 1"
    And I should see "Pseud's Work 7"
    
  # Check the Series link for the pseud
  When I follow "tester" within ".pseud .expandable li"
  Then I should see "Recent series"
    And I should see "Pseud Series E"
    And I should not see "Pseud Series A"
    And I should see "Series (6)" within "#user-series"
  When I follow "Series (6)" within "#user-series"
    And I should see "Pseud Series E"
    And I should see "Pseud Series A"

  # Create 7 bookmarks for the user
  When I follow "tester" within ".pseud .expandable li"
    And I follow "Works (7)"
  When I follow "Pseud's Work 1"
    And I follow "Bookmark"
    And I press "Create"
  Then I should see "Bookmark was successfully created."
  When I follow "tester (testy)"
    And I follow "Works (7)"
    And I follow "Pseud's Work 2"
    And I follow "Bookmark"
    And I press "Create"
  Then I should see "Bookmark was successfully created."
  When I follow "tester (testy)"
    And I follow "Works (7)"
    And I follow "Pseud's Work 3"
    And I follow "Bookmark"
    And I press "Create"
  Then I should see "Bookmark was successfully created."
  When I follow "tester (testy)"
    And I follow "Works (7)"
    And I follow "Pseud's Work 4"
    And I follow "Bookmark"
    And I press "Create"
  Then I should see "Bookmark was successfully created."
  When I follow "tester (testy)"
    And I follow "Works (7)"
    And I follow "Pseud's Work 5"
    And I follow "Bookmark"
    And I press "Create"
  Then I should see "Bookmark was successfully created."
  When I follow "tester (testy)"
    And I follow "Works (7)"
    And I follow "Pseud's Work 6"
    And I follow "Bookmark"
    And I press "Create"
  Then I should see "Bookmark was successfully created."
  When I follow "tester (testy)"
    And I follow "Works (7)"
    And I follow "Pseud's Work 7"
    And I follow "Bookmark"
    And I press "Create"
  Then I should see "Bookmark was successfully created."

  # Check the Bookmarks link for the user
  When I go to testy's user page
  Then I should see "Recent bookmarks"
    And I should see "Bookmarks (7)" within "#user-bookmarks"
  When I follow "Bookmarks (7)" within "#user-bookmarks"
  Then I should see "7 Bookmarks by testy"

  # Create a bookmark for the pseud and make sure the user's bookmark count doesn't carry over
  When I go to testy's user page
    And I follow "Works (13)"
  When I follow "Oldest Work"
    And I follow "Bookmark"
    And I select "tester" from "bookmark_pseud_id"
    And I press "Create"
  Then I should see "Bookmark was successfully created."
  When I follow "testy"
    And I follow "tester" within ".pseud .expandable li"
  Then I should see "Recent bookmarks"
    And I should see "Oldest Work"
    And I should not see "Bookmarks (" within "#user-bookmarks"

  # Create 5 more bookmarks for the pseud
  When I go to testy's user page
    And I follow "Works (13)"
    And I follow "Work 2"
    And I follow "Bookmark"
    And I select "tester" from "bookmark_pseud_id"
    And I press "Create"
  Then I should see "Bookmark was successfully created."
  When I follow "testy"
    And I follow "Works (13)"
    And I follow "Work 3"
    And I follow "Bookmark"
    And I select "tester" from "bookmark_pseud_id"
    And I press "Create"
  When I follow "testy"
    And I follow "Works (13)"
    And I follow "Work 4"
    And I follow "Bookmark"
    And I select "tester" from "bookmark_pseud_id"
    And I press "Create"
  When I follow "testy"
    And I follow "Works (13)"
    And I follow "Work 5"
    And I follow "Bookmark"
    And I select "tester" from "bookmark_pseud_id"
    And I press "Create"
  When I follow "testy"
    And I follow "Works (13)"
    And I follow "Newest Work"
    And I follow "Bookmark"
    And I select "tester" from "bookmark_pseud_id"
    And I press "Create"
  Then I should see "Bookmark was successfully created."

  # Check the Bookmarks link for the pseud
  When I go to testy's user page
    And I follow "tester" within ".pseud .expandable li"
  Then I should see "Recent bookmarks"
    And I should see "Bookmarks (6)" within "#user-bookmarks"