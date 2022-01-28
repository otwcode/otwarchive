@tags @tag_wrangling @search
Feature: Search Tags
  In order to find tags
  As a user
  I want to use tag search

  Scenario: Search tags
    Given I have no tags
      And a fandom exists with name: "first fandom", canonical: false
      And a character exists with name: "first last", canonical: true
      And a relationship exists with name: "first last/someone else", canonical: false
      And all indexing jobs have been run
    When I am on the search tags page
      And I fill in "Tag name" with "first"
      And I press "Search Tags"
    Then I should see "3 Found"
      And I should see the tag search result "Fandom: first fandom (0)"
      And I should not see the tag search result "Fandom: first fandom (0)" within ".canonical"
      And I should see the tag search result "Character: first last (0)" within ".canonical"
      And I should see the tag search result "Relationship: first last/someone else (0)"
  # test search with slash
    When I am on the search tags page
      And I fill in "Tag name" with "first last\/someone else"
      And I press "Search Tags"
    Then I should see "1 Found"
      And I should see the tag search result "first last/someone else (0)"

    Scenario: Search for fandom with slash in name
      Given I have no tags
        And a fandom exists with name: "first/fandom", canonical: false
        And all indexing jobs have been run
      When I am on the search tags page
        And I fill in "Tag name" with "first"
        And I press "Search Tags"
      Then I should see "1 Found"
        And I should see the tag search result "Fandom: first/fandom (0)"

    Scenario: Search for fandom with period in name
      Given I have no tags
        And a fandom exists with name: "first.fandom", canonical: false
        And all indexing jobs have been run
      When I am on the search tags page
        And I fill in "Tag name" with "first.fandom"
        And I press "Search Tags"
      Then I should see "1 Found"
        And I should see the tag search result "Fandom: first.fandom (0)"
      When I follow "first.fandom"
      Then I should see "This tag belongs to the Fandom Category"

	Scenario: Search for tag in canonical fandom(s)
	  Given I have no tags
		And a fandom exists with name: "Fandom A", canonical: true
		And a fandom exists with name: "Fandom B", canonical: true
		And I add the fandom "Fandom A" to the character "Anna Anderson"
		And I add the fandom "Fandom A" to the character "Abby Anderson"
		And I add the fandom "Fandom B" to the character "Abby Anderson"
		And a character exists with name: "Null Anderson"
		And all indexing jobs have been run
	 # Tag in one canonical fandom
	When I am on the search tags page
		And I fill in "Tag name" with "Anderson"
		And I fill in "Fandom" with "Fandom A"
        And I press "Search Tags"
	Then I should see "2 Found"
		And I should see the tag search result "Anna Anderson"
		And I should see the tag search result "Abby Anderson"
		And I should not see the tag search result "Null Anderson"
	 # Tag in multiple canonical fandoms
	  When I am on the search tags page
		And I fill in "Tag name" with "Anderson"
		And I fill in "Fandom" with "Fandom A, Fandom B"
        And I press "Search Tags"
      Then I should see "1 Found"
		And I should see the tag search result "Abby Anderson"
		And I should not see the tag search result "Anna Anderson"
		And I should not see the tag search result "Null Anderson"

	Scenario: Search by Type of tags
      Given I have no tags
        And a fandom exists with name: "first fandom"
        And a character exists with name: "first character"
        And a relationship exists with name: "first last/someone else"
        And a freeform exists with name: "first fic please be nice"
        And all indexing jobs have been run
      When I am on the search tags page
        And I fill in "Tag name" with "first"
        And I choose "Fandom"
        And I press "Search Tags"
      Then I should see "1 Found"
        And I should see the tag search result "Fandom: first fandom"
        And I should not see the tag search result "Character: first character"
        And I should not see the tag search result "Relationship: first last/somone else"
        And I should not see the tag search result "Freeform: first fic, please be nice"
      When I am on the search tags page
        And I fill in "Tag name" with "first"
        And I choose "Character"
        And I press "Search Tags"
      Then I should see "1 Found"
        And I should see the tag search result "Character: first character"
        And I should not see the tag search result "Fandom: first fandom"
        And I should not see the tag search result "Relationship: first last/somone else"
        And I should not see the tag search result "Freeform: first fic, please be nice"
      When I am on the search tags page
        And I fill in "Tag name" with "first"
        And I choose "Relationship"
        And I press "Search Tags"
      Then I should see "1 Found"
        And I should see the tag search result "Relationship: first last/somone else"
        And I should not see the tag search result "Fandom: first fandom"
        And I should not see the tag search result "Character: first character"
        And I should not see the tag search result "Freeform: first fic, please be nice"
      When I am on the search tags page
        And I fill in "Tag name" with "first"
        And I choose "Freeform"
        And I press "Search Tags"
      Then I should see "1 Found"
        And I should see the tag search result "Freeform: first fic, please be nice"
        And I should not see the tag search result "Fandom: first fandom"
        And I should not see the tag search result "Character: first character"
        And I should not see the tag search result "Relationship: first last/somone else"

	Scenario: Search by wrangling status
      Given I have no tags
        And a fandom exists with name: "Not Canon Fandom", canonical: false
        And a character exists with name: "Canon Character", canonical: true
        And all indexing jobs have been run
      When I am on the search tags page
        And I fill in "Tag name" with "Canon"
        And I choose "Canonical"
        And I press "Search Tags"
      Then I should see "1 Found"
        And I should see the tag search result "Character: Canon Character (0)"
        And I should not see the tag search result "Fandom: Not Canon Fandom (0)"
      When I am on the search tags page
        And I fill in "Tag name" with "Canon"
        And I choose "Non-canonical"
        And I press "Search Tags"
      Then I should see "1 Found"
        And I should see the tag search result "Fandom: Not Canon Fandom (0)"
        And I should not see the tag search result "Character: Canon Character (0)"
      When I am on the search tags page
        And I fill in "Tag name" with "Canon"
        And I choose "Any status"
        And I press "Search Tags"
      Then I should see "2 Found"
        And I should see the tag search result "Fandom: Not Canon Fandom (0)"
        And I should see the tag search result "Character: Canon Character (0)"

	Scenario: Search and sort by Date Created
      Given I have no tags
        And a freeform exists with name: "created first", created_at: "2008-01-01 20:00:00 Z"
		And a freeform exists with name: "created second", created_at: "2009-01-01 20:00:00 Z"
		And a freeform exists with name: "created third", created_at: "2010-01-01 20:00:00 Z"
		And a freeform exists with name: "created fourth", created_at: "2011-01-01 20:00:00 Z"
        And all indexing jobs have been run
      When I am on the search tags page
        And I fill in "Tag name" with "created"
		And I select "Date Created" from "tag_search_sort_column"
        And I press "Search Tags"
      Then I should see "4 Found"
		  And the 1st tag result should contain "created fourth"
		  And the 2nd tag result should contain "created third"
		  And the 3rd tag result should contain "created second"
		  And the 4th tag result should contain "created first"

	Scenario: Search and sort by Uses
      Given I have no tags
        And a freeform exists with name: "10 uses"
        And a freeform exists with name: "8 uses"
        And a freeform exists with name: "also 8 uses"
        And a freeform exists with name: "5 uses"
        And a freeform exists with name: "2 uses"
        And a freeform exists with name: "0 uses"
		And a set of works for tag sort by use exists
        And all indexing jobs have been run
      When I am on the search tags page
	    And I fill in "Tag name" with "uses"
		And I select "Uses" from "tag_search_sort_column"
        And I press "Search Tags"
      Then I should see "6 Found"
		And the 1st tag result should contain "10 uses"
		And the 2nd tag result should contain "8 uses"
		And the 3rd tag result should contain "8 uses"
		And the 4th tag result should contain "5 uses"
		And the 5th tag result should contain "2 uses"
		And the 6th tag result should contain "0 uses"

      # If this was a bug, it's fixed now?
      # When I am on the search tags page
      # possibly a bug rather than desired behaviour, to be discussed later
      #   And I fill in "Tag name" with "first"
      #   And I press "Search Tags"
      # Then I should see "0 Found"
      #   And I should not see "Fandom: first.fandom (0)"
