@no-txn @works @search
Feature: Search Works
  In order to test search
  As a humble coder
  I have to use Cucumber with Elasticsearch

  Scenario: Works that are anonymous do not show up in searches for the
  creator's name
      Given I have the Battle set loaded
      When I search for works containing "mod1"
      Then I should see "You searched for: mod1"
        And I should see "No results found"
      When I search for works by "mod1"
      Then I should see "You searched for: creator: mod1"
        And I should see "No results found"

  Scenario: Works that are anonymous should show up in searches for the
  creator Anonymous
    Given I have the Battle set loaded
    When I search for works containing "Anonymous"
    Then I should see "You searched for: Anonymous"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I search for works by "Anonymous"
    Then I should see "You searched for: creator: Anonymous"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I go to the search works page
      And I fill in "Author/Artist" with "Anonymous"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Author/Artist: Anonymous"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"

  Scenario: Works that used to be anonymous show up in searches for the
  creator's name once the creator is revealed
    Given I have the Battle set loaded
      And I reveal the authors of the "Battle 12" challenge
      And all search indexes are updated
    When I search for works containing "mod1"
    Then I should see "You searched for: mod1"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I search for works by "mod1"
    Then I should see "You searched for: creator: mod1"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"
    When I go to the search works page
      And I fill in "Author/Artist" with "mod1"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Author/Artist: mod1"
      And I should see "1 Found"
      And I should see "Fulfilled Story-thing"

  Scenario: Search by language
    Given I have the Battle set loaded
    When I am on the search works page
      And I select "Deutsch" from "Language"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Language: Deutsch"
      And I should see "1 Found"
      And the 1st result should contain "Language: Deutsch"
    When I follow "Edit Your Search"
    Then "Deutsch" should be selected within "Language"

  Scenario: Search by range of hits
    Given I have the Battle set loaded
    When I am on the search works page
      And I fill in "Hits" with "10000-20000"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: hits: 10000-20000"
      And I should see "1 Found"
      And the 1st result should contain "Hits: 10000"
    When I follow "Edit Your Search"
    Then the field labeled "Hits" should contain "10000-20000"

  Scenario: Search by date and then refine by word count
    Given I have the Battle set loaded
    When I am on the search works page
      And I fill in "Date" with "> 2 years ago"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: revised at: > 2 years ago"
      And I should see "6 Found"
      And I should see "First work"
      And I should see "second work"
      And I should see "third work"
      And I should see "fourth"
      And I should see "fifth"
      And I should see "I am <strong>er Than Yesterday & Other Lies"
    When I follow "Edit Your Search"
    Then I should be on the search works page
      And the field labeled "Date" should contain "> 2 years ago"
    When I fill in "Word Count" with ">15000"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: word count: >15000 revised at: > 2 years ago"
      And I should see "No results found"

  Scenario: Search by > hits
    Given I have the Battle set loaded
    When I am on the search works page
      And I fill in "Hits" with "> 100"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: hits: > 100"
      And I should see "2 Found"
      And I should see "First work"
      And I should see "third work"
    When I follow "Edit Your Search"
    Then the field labeled "Hits" should contain "> 100"

  Scenario: Search with the header search field and then refine by author/artist
    Given I have the Battle set loaded
    When I fill in "site_search" with "testuser2"
      And I press "Search"
    Then I should see "You searched for: testuser2"
      And I should see "3 Found"
      And I should see "I am <strong>er Than Yesterday & Other Lies"
      And I should see "fourth"
      And I should see "fifth"
    When I follow "Edit Your Search"
    Then I should be on the search works page
      And the field labeled "Any Field" should contain "testuser2"
    When I fill in "Any Field" with ""
      And I fill in "Author/Artist" with "testuser2"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Author/Artist: testuser2"
      And I should see "3 Found"
      And I should see "fourth"
      And I should see "fifth"
      And I should see "I am <strong>er Than Yesterday & Other Lies"

  Scenario: Search and sort by number of kudos
    Given I have the Battle set loaded
    When I am on the search works page
      And I fill in "Kudos" with ">0"
      And I select "Kudos" from "Sort by"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: >0 sort by: kudos descending"
      And I should see "2 Found"
      And the 1st result should contain "Kudos: 4"
      And the 2nd result should contain "Kudos: 1"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain ">0"
      And "Kudos" should be selected within "Sort by"
    When I fill in "Kudos" with "5"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: 5 sort by: kudos descending"
      And I should see "No results found"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "5"
    When I fill in "Kudos" with "4"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: 4 sort by: kudos descending"
      And I should see "1 Found"
      And the 1st result should contain "Kudos: 4"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "4"
    When I fill in "Kudos" with "<2"
      And I select "Ascending" from "Sort direction"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: kudos count: <2 sort by: kudos ascending"
      And I should see "6 Found"
      And I should see "second work"
      And I should see "third work"
      And I should see "fourth"
      And I should see "fifth"
      And I should see "I am <strong>er Than Yesterday & Other Lies"
      And I should see "Fulfilled Story-thing"
      And the 6th result should contain "Kudos: 1"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "<2"
      And "Kudos" should be selected within "Sort by"
    When "AO3-5020" is fixed
      # And "Ascending" should be selected within "Sort direction"
    When I check "Complete"
      And I press "Search" within "#new_work_search"
    When "AO3-5020" is fixed
    # Then I should see "You searched for: Complete kudos count: <2 sort by: kudos ascending"
      And I should see "4 Found"
      And I should see "second work"
      And I should see "third work"
      And I should see "fourth"
      And I should see "Fulfilled Story-thing"
    When "AO3-5020" is fixed
      # And the 4th result should contain "Kudos: 1"
    When I follow "Edit Your Search"
    Then the field labeled "Kudos" should contain "<2"
      And the "Complete" checkbox should be checked
    When "AO3-5020" is fixed
      # And "Ascending" should be selected within "Sort direction"

  Scenario: Search by single chapter
    Given I have the Battle set loaded
    When I am on the search works page
      And I check "Single Chapter"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Single Chapter"
      And I should see "4 Found"
      And I should see "First work"
      And I should see "second work"
      And I should see "fourth"
      And I should see "Fulfilled Story-thing"
    When I follow "Edit Your Search"
    Then the "Single Chapter" checkbox should be checked

  Scenario: Search and sort by title
    Given I have loaded the fixtures
    When I am on the search works page
      And I fill in "Title" with "work"
      And I select "Title" from "Sort by"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Title: work sort by: title descending"
      And I should see "3 Found"
      And the 1st result should contain "third work"
      And the 2nd result should contain "second work"
      And the 3rd result should contain "First work"
    When I follow "Edit Your Search"
    Then the field labeled "Title" should contain "work"
      And "Title" should be selected within "Sort by"
    When I select "Ascending" from "Sort direction" 
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Title: work sort by: title ascending"
      And I should see "3 Found"
      And the 1st result should contain "First work"
      And the 2nd result should contain "second work"
      And the 3rd result should contain "third work"
    When I follow "Edit Your Search"
    Then the field labeled "Title" should contain "work"
      And "Title" should be selected within "Sort by"
    When "AO3-5020" is fixed
      # And "Ascending" should be selected within "Sort direction"

  Scenario: Search by exact number of comments
    Given a set of works with comments for searching
    When I am on the search works page
      And I fill in "Comments" with "1"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: comments count: 1"
      And I should see "3 Found"
    When I follow "Edit Your Search"
    Then the field labeled "Comments" should contain "1"

  Scenario: Search by a range of comments
    Given a set of works with comments for searching
    When I am on the search works page
      And I fill in "Comments" with "1-5"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: comments count: 1-5"
      And I should see "5 Found"
    When I follow "Edit Your Search"
    Then the field labeled "Comments" should contain "1-5"

  Scenario: Search by > a number of comments and sort in ascending order by
  comments
    Given a set of works with comments for searching
    When I am on the search works page
      And I fill in "Comments" with "> 0"
      And I select "Comments" from "Sort by"
      And I select "Ascending" from "Sort direction"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: comments count: > 0 sort by: comments ascending"
      And I should see "6 Found"
      And the 1st result should contain "Comments: 1"
      And the 2nd result should contain "Comments: 1"
      And the 3rd result should contain "Comments: 1"
      And the 4th result should contain "Comments: 3"
      And the 5th result should contain "Comments: 3"
      And the 6th result should contain "Comments: 10"
    When I follow "Edit Your Search"
    Then the field labeled "Comments" should contain "> 0"
      And "Comments" should be selected within "Sort by"
    When "AO3-5020" is fixed
      # And "Ascending" should be selected within "Sort direction"

  Scenario: Search by < a number of comments and sort in descending order by
  comments
    Given a set of works with comments for searching
    When I am on the search works page
      And I fill in "Comments" with "<20"
      And I select "Comments" from "Sort by"
      And I select "Descending" from "Sort direction"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: comments count: <20 sort by: comments descending"
      And I should see "7 Found"
      And the 1st result should contain "Comments: 10"
      And the 2nd result should contain "Comments: 3"
      And the 3rd result should contain "Comments: 3"
      And the 4th result should contain "Comments: 1"
      And the 5th result should contain "Comments: 1"
      And the 6th result should contain "Comments: 1"
    When I follow "Edit Your Search"
    Then the field labeled "Comments" should contain "<20"
      And "Comments" should be selected within "Sort by"
    When "AO3-5020" is fixed
      # And "Descending" should be selected within "Sort direction"

  Scenario: Search by > a number of comments and sort in ascending order by
  title using the header search
    Given a set of works with comments for searching
    When I fill in "site_search" with "comments: > 2 sort: title ascending"
      And I press "Search"
    Then I should see "You searched for: comments count: > 2 sort by: title ascending"
      And I should see "3 Found"
      And the 1st result should contain "Work 5"
      And the 2nd result should contain "Work 6"
      And the 3rd result should contain "Work 7"
    When I follow "Edit Your Search"
    Then the field labeled "Comments" should contain "> 2"
      And "Title" should be selected within "Sort by"
    When "AO3-5020" is fixed
      # And "Ascending" should be selected within "Sort direction"

  Scenario: Search by exact number of bookmarks
    Given a set of works with bookmarks for searching
    When I am on the search works page
      And I fill in "Bookmarks" with "1"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: bookmarks count: 1"
      And I should see "2 Found"
    When I follow "Edit Your Search"
    Then the field labeled "Bookmarks" should contain "1"

  Scenario: Search by a range of bookmarks
    Given a set of works with bookmarks for searching
    When I am on the search works page
      And I fill in "Bookmarks" with "2 - 5"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: bookmarks count: 2 - 5"
      And I should see "3 Found"
    When I follow "Edit Your Search"
    Then the field labeled "Bookmarks" should contain "2 - 5"

  Scenario: Search by > a number of bookmarks and sort in ascending order by
  bookmarks
    Given a set of works with bookmarks for searching
    When I am on the search works page
      And I fill in "Bookmarks" with ">1"
      And I select "Bookmarks" from "Sort by"
      And I select "Ascending" from "Sort direction"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: bookmarks count: >1 sort by: bookmarks ascending"
      And I should see "4 Found"
      # TODO: Figure out how to fix caching issue
      # And the 1st result should contain "Bookmarks: 2"
      # And the 2nd result should contain "Bookmarks: 2"
      # And the 3rd result should contain "Bookmarks: 4"
      # And the 4th result should contain "Bookmarks: 10"
    When I follow "Edit Your Search"
    Then the field labeled "Bookmarks" should contain ">1"
      And "Bookmarks" should be selected within "Sort by"
    When "AO3-5020" is fixed
      # And "Ascending" should be selected within "Sort direction"

  Scenario: Search by < a number of bookmarks and sort in descending order by
  bookmarks
    Given a set of works with bookmarks for searching
    When I am on the search works page
      And I fill in "Bookmarks" with "< 20"
      And I select "Bookmarks" from "Sort by"
      And I select "Descending" from "Sort direction"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: bookmarks count: < 20 sort by: bookmarks descending"
      And I should see "7 Found"
      # TODO: Figure out how to fix caching issue
      # And the 1st result should contain "Bookmarks: 10"
      # And the 2nd result should contain "Bookmarks: 4"
      # And the 3rd result should contain "Bookmarks: 2"
      # And the 4th result should contain "Bookmarks: 2"
      # And the 5th result should contain "Bookmarks: 1"
      # And the 6th result should contain "Bookmarks: 1"
    When I follow "Edit Your Search"
    Then the field labeled "Bookmarks" should contain "< 20"
      And "Bookmarks" should be selected within "Sort by"
    When "AO3-5020" is fixed
      # And "Descending" should be selected within "Sort direction"

  Scenario: Search by > a number of bookmarks and sort in ascending order by
  title using the header search
    Given a set of works with bookmarks for searching
    When I fill in "site_search" with "bookmarks: > 2 sort by: title ascending"
      And I press "Search"
    Then I should see "You searched for: bookmarks count: > 2 sort by: title ascending"
      And I should see "2 Found"
      And the 1st result should contain "Work 6"
      And the 2nd result should contain "Work 7"
    When I follow "Edit Your Search"
    Then the field labeled "Bookmarks" should contain "> 2"
      And "Title" should be selected within "Sort by"
    When "AO3-5020" is fixed
      # And "Ascending" should be selected within "Sort direction"

  Scenario: Searching for a fandom in the header search returns works with (a)
  the exact tag, (b) the tag's syns, (c) the tag's subtags and _their_ syns, and
  (d) any other tags or text matching the search term; refining the search with
  the fandom field returns only works with (a), (b), or (c)
    Given a set of Star Trek works for searching
    When I search for works containing "Star Trek"
    Then I should see "You searched for: Star Trek"
      And I should see "6 Found"
      And the results should contain the fandom tag "Star Trek"
      And the results should contain the subtags of "Star Trek"
      # A synonym of one of the Star Trek subtags
      And the results should contain the fandom tag "ST: TOS"
      And the results should contain a freeform mentioning "Star Trek"
    When I follow "Edit Your Search"
    Then the field labeled "Any Field" should contain "Star Trek"
    When I fill in "Fandoms" with "Star Trek"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Star Trek Tags: Star Trek"
      And I should see "5 Found"
      And the results should contain the fandom tag "Star Trek"
      And the results should contain the subtags of "Star Trek"
      # A synonym of one of the Star Trek subtags
      And the results should contain the fandom tag "ST: TOS"
      And the results should not contain a freeform mentioning "Star Trek"
    When I follow "Edit Your Search"
    Then the field labeled "Any Field" should contain "Star Trek"
      And the field labeled "Fandoms" should contain "Star Trek"

  Scenario: Searching by fandom for a tag that does not exist returns 0 results
    Given a set of Star Trek works for searching
    When I am on the search works page
      And I fill in "Fandoms" with "Star Trek: The Next Generation"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Star Trek: The Next Generation"
      And I should see "No results found."
      And I should see "You may want to edit your search to make it less specific."

  # We use JavaScript here because otherwise there is a minor spacing issue with
  # "You searched for" on the results page and the coder who wrote this test was
  # offended by it
  @javascript
  Scenario: Searching by fandom for two fandoms returns only works tagged with
  both fandoms (or syns or subtags of those fandoms)
    Given a set of Star Trek works for searching
    When I am on the search works page
      And I fill in "Fandoms" with "Star Trek, Battlestar Galactica (2003)"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Star Trek, Battlestar Galactica (2003)"
      And I should see "1 Found"
      # A synonym of one of the Star Trek subtags
      And the results should contain the fandom tag "ST: TOS"
      And the results should contain the fandom tag "Battlestar Galactica (2003)"
    When I follow "Edit Your Search"
    Then "Star Trek" should already be entered in the work search fandom autocomplete field
      And "Battlestar Galactica (2003)" should already be entered in the work search fandom autocomplete field

  Scenario: Searching by rating returns only works using that rating
    Given a set of works with various ratings for searching
    When I am on the search works page
      And I select "Teen And Up Audiences" from "Rating"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Teen And Up Audiences"
      And I should see "1 Found"
      And the results should contain the rating tag "Teen And Up Audiences"
    When I follow "Edit Your Search"
    Then "Teen And Up Audiences" should be selected within "Rating"

  Scenario: Searching for Explicit or Mature in the header returns works with
  (a) either rating or (b) other tags or text matching either rating; editing
  the search to use the ratings' filter_ids returns only (a)
    Given a set of works with various ratings for searching
    When I search for works containing "Mature || Explicit"
    Then I should see "You searched for: Mature || Explicit"
      And I should see "3 Found"
      And the results should contain the rating tag "Mature"
      And the results should contain the rating tag "Explicit"
      And the results should contain a summary mentioning "explicit"
    When I follow "Edit Your Search"
    Then the field labeled "Any Field" should contain "Mature || Explicit"
    When I exclude the tags "Mature" and "Explicit" by filter_id
      And I press "Search" within "#new_work_search"
    Then the search summary should include the filter_id for "Mature"
      And the search summary should include the filter_id for "Explicit"
      And the results should not contain the rating tag "Mature"
      And the results should not contain the rating tag "Explicit"

  Scenario: Using Any Field to exclude works using (a) one of the two ratings or (b) other tags or text matching either rating
    Given a set of works with various ratings for searching
    When I am on the search works page
      And I fill in "Any Field" with "-Mature -Explicit"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: -Mature -Explicit"
      And I should see "3 Found"
      And the results should contain the rating tag "General Audiences"
      And the results should contain the rating tag "Teen And Up Audiences"
      And the results should contain the rating tag "Not Rated"
      And the results should not contain a summary mentioning "explicit"
    When I follow "Edit Your Search"
    Then the field labeled "Any Field" should contain "-Mature -Explicit"

  Scenario: Searching by warning returns all works using that warning tag
    Given a set of works with various warnings for searching
    When I am on the search works page
      And I check "No Archive Warnings Apply"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: No Archive Warnings Apply"
      And I should see "2 Found"
      And the 1st result should contain "No Archive Warnings Apply"
      And the 2nd result should contain "No Archive Warnings Apply"
    When I follow "Edit Your Search"
    Then the "No Archive Warnings Apply" checkbox should be checked
  
  Scenario: Using the header search to exclude works with certain warnings using the warnings' filter_ids
    Given a set of works with various warnings for searching
    When I search for works without the "Rape/Non-Con" and "Underage" filter_ids
    Then the search summary should include the filter_id for "Rape/Non-Con"
      And the search summary should include the filter_id for "Underage"
      And I should see "5 Found"
      And the results should not contain the warning tag "Underage"
      And the results should not contain the warning tag "Rape/Non-Con"

  Scenario: Searching by category returns all works using that category; search
  can be refined using Any Field to return works using only that category
    Given a set of works with various categories for searching
    When I am on the search works page
      And I check "F/F"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: F/F"
      And I should see "2 Found"
      And the results should contain the category tag "F/F"
      And the results should contain the category tag "M/M, F/F"
    When I follow "Edit Your Search"
    Then the "F/F" checkbox should be checked
    When I fill in "Any Field" with "-M/M"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: -M/M Tags: F/F"
      And I should see "1 Found"

  Scenario: Searching by category for Multi only returns works tagged with the
  Multi category, not works tagged with multiple categories
    Given a set of works with various categories for searching
    When I am on the search works page
      And I check "Multi"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Multi"
      And I should see "1 Found"
      And the results should contain the category tag "Multi"
      And the results should not contain the category tag "M/M, F/F"
    When I follow "Edit Your Search"
    Then the "Multi" checkbox should be checked

  Scenario: Searching for a character in the header search returns works with
  (a) the exact tag, (b) the tag's syns, or (c) any other tags or text matching
  the search term
    Given a set of Steve Rogers works for searching
    When I search for works containing "Steve Rogers"
    Then I should see "You searched for: Steve Rogers"
      And I should see "6 Found"
      And the results should contain the character tag "Steve Rogers"
      And the results should contain a synonym of "Steve Rogers"
      And the results should contain a relationship mentioning "Steve Rogers"
      And the results should contain a summary mentioning "Steve Rogers"
    When I follow "Edit Your Search"
    Then the field labeled "Any Field" should contain "Steve Rogers"

  Scenario: Searching by character for a tag with synonyms returns works using
  the exact tag or its synonyms
    Given a set of Steve Rogers works for searching
    When I am on the search works page
      And I fill in "Characters" with "Steve Rogers"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Steve Rogers"
      And I should see "4 Found"
      And the results should contain the character tag "Steve Rogers"
      And the results should contain a synonym of "Steve Rogers"
      And the results should not contain a relationship mentioning "Steve Rogers"
      And the results should not contain a summary mentioning "Steve Rogers"
    When I follow "Edit Your Search"
    Then the field labeled "Characters" should contain "Steve Rogers"

  Scenario: Searching for a relationship in the header search returns works
  with (a) the exact tag and (b) the tag's syns, and (c) any other tags or text
  matching the search term (e.g. a threesome); refining the search with the
  relationship field returns only (a) or (b)
    Given a set of Spock/Uhura works for searching
    When I search for works containing "Spock/Nyota Uhura"
    Then I should see "You searched for: Spock/Nyota Uhura"
      And I should see "3 Found"
      And the results should contain the relationship tag "Spock/Nyota Uhura"
      And the results should contain a synonym of "Spock/Nyota Uhura"
      And the results should contain the relationship tag "James T. Kirk/Spock/Nyota Uhura"
    When I follow "Edit Your Search"
    Then the field labeled "Any Field" should contain "Spock/Nyota Uhura"
    When I fill in "Relationships" with "Spock/Nyota Uhura"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Spock/Nyota Uhura Tags: Spock/Nyota Uhura"
      And I should see "2 Found"
      And the results should contain the relationship tag "Spock/Nyota Uhura"
      And the results should contain a synonym of "Spock/Nyota Uhura"
      And the results should not contain the relationship tag "James T. Kirk/Spock/Nyota Uhura"

  Scenario: Searching by relationship returns works using the exact tag or its
  synonyms
    Given a set of Kirk/Spock works for searching
    When I am on the search works page
      And I fill in "Relationships" with "James T. Kirk/Spock"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: James T. Kirk/Spock"
      And I should see "4 Found"
      And the results should contain the relationship tag "James T. Kirk/Spock"
      And the results should contain the synonyms of "James T. Kirk/Spock"
    When I follow "Edit Your Search"
    Then the field labeled "Relationships" should contain "James T. Kirk/Spock"

  Scenario: Searching by relationship and category returns only works using the
  category and the exact relationship tag or its synonyms
    Given a set of Kirk/Spock works for searching
    When I am on the search works page
      And I fill in "Relationships" with "James T. Kirk/Spock"
      And I check "F/M"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: F/M, James T. Kirk/Spock"
      And I should see "1 Found"
      And the results should contain the category tag "F/M"
      And the results should contain a synonym of "James T. Kirk/Spock"
    When I follow "Edit Your Search"
    Then the field labeled "Relationships" should contain "James T. Kirk/Spock"
      And the "F/M" checkbox should be checked

  Scenario: Searching by additional tags (freeforms) for a metatag with synonyms
  and subtags should return works using (a) the exact tag, (b) its synonyms, (c)
  its subtags, and (d) its subtags' synonyms
    Given a set of alternate universe works for searching
    When I am on the search works page
      And I fill in "Additional Tags" with "Alternate Universe"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Alternate Universe"
      And I should see "4 Found"
      And the results should contain the freeform tag "Alternate Universe"
      And the results should contain a synonym of "Alternate Universe"
      And the results should contain the freeform tag "High School AU"
      And the results should contain the freeform tag "Alternate Universe - Coffee Shops & Cafés"
      And the results should not contain the freeform tag "Coffee Shop AU"
    When I follow "Edit Your Search"
    Then the field labeled "Additional Tags" should contain "Alternate Universe"

  Scenario: Searching by additional tags (freeforms) for a synonym of a metatag
  returns works using (a) the exact tag or (b) other tags containing the search
  term, regardless of tag type
    Given a set of alternate universe works for searching
    When I am on the search works page
      And I fill in "Additional Tags" with "AU"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: AU"
      And I should see "4 Found"
      And the results should contain the freeform tag "AU"
      And the results should contain the freeform tag "High School AU"
      And the results should contain the freeform tag "Coffee Shop AU"
      And the results should contain a character mentioning "AU"
    When I follow "Edit Your Search"
    Then the field labeled "Additional Tags" should contain "AU"

  Scenario: Searching by additional tags (freeforms) for a tag with no direct
  uses returns works using the tag's synonyms
    Given a set of alternate universe works for searching
    When I am on the search works page
      And I fill in "Additional Tags" with "Alternate Universe - High School"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Alternate Universe - High School"
      And I should see "1 Found"
      And the results should contain a synonym of "Alternate Universe - High School"
    When I follow "Edit Your Search"
    Then the field labeled "Additional Tags" should contain "Alternate Universe - High School"

  Scenario: Searching by additional tags (freeforms) for a tag that has not been
  wrangled returns only works using tags containing the search term (not 
  summaries, titles, etc)
    Given a set of alternate universe works for searching
    When I am on the search works page
      And I fill in "Additional Tags" with "Coffee Shop AU"
      And I press "Search" within "#new_work_search"
    Then I should see "You searched for: Tags: Coffee Shop AU"
      And I should see "1 Found"
      And the results should contain the freeform tag "Coffee Shop AU"
      And the results should not contain a summary mentioning "Coffee Shop AU"
    When I follow "Edit Your Search"
    Then the field labeled "Additional Tags" should contain "Coffee Shop AU"

  Scenario: Search results for logged out users should contain only posted works
  that are public; they should not contain works that are drafts, restricted to
  registered users, or hidden by an admin
    Given a set of works with various access levels for searching
      And I am logged out
    When I search for works containing "Work"
    Then I should see "You searched for: Work"
      And I should see "1 Found"
      And I should see "Posted Work"
      And I should not see "Restricted Work"
      And I should not see "Work Hidden by Admin"
      And I should not see "Draft Work"

  Scenario: Search results for logged in users should contain only posted works
  that are public or restricted to registered users; they should not contain
  drafts or works hidden by an admin
    Given a set of works with various access levels for searching
      And I am logged in as a random user
    When I search for works containing "Work"
    Then I should see "You searched for: Work"
      And I should see "2 Found"
      And I should see "Posted Work"
      And I should see "Restricted Work"
      And I should not see "Work Hidden by Admin"
      And I should not see "Draft Work"

  Scenario: Searching for restricted works only returns results for logged in
  users or admins
    Given a set of works with various access levels for searching
      And I am logged in as a random user
    When I search for works containing "restricted: T"
    Then I should see "You searched for: restricted: T"
      And I should see "1 Found"
      And the results should contain only the restricted work
    When I am logged out
      And I search for works containing "restricted: T"
    Then I should see "You searched for: restricted: T"
      And I should see "No results found."
    When I am logged in as an admin
      And I search for works containing "restricted: T"
    Then I should see "1 Found"
      And the results should contain only the restricted work
