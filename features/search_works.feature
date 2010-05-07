@works
Feature: Search Works
  In order to test search
  As a humble coder
  I have to use cucumber with thinking sphinx

  Scenario: Search works from univeral search box
    Given I have loaded the fixtures
      And the Sphinx indexes are updated
    When I am on the homepage
      And I fill in "site_search" with "first"
      And I press "Search"
    Then I should see "3 Found"
    When I follow "Advanced search"
    Then I should be on the advanced search page
    When I fill in "refine_text" with ""
      And I fill in "refine_tag" with "second"
      And I press "Search works"
    Then I should see "1 Found"
    When I am on the advanced search page
      And I fill in "refine_language" with "Deutsch"
      And I press "Search works"
    Then I should see "1 Found"
    
    
  Scenario: Search for some different works from universal search box
    Given I have loaded the fixtures
      And the Sphinx indexes are updated
    When I am on the homepage
      And I fill in "site_search" with "hits: >10"
      And I press "Search"
    Then I should see "2 Found"
    When I follow "Advanced search"
    Then I should be on the advanced search page
    When I fill in "refine_hit_count" with "10000-20000"
      And I press "Search works"
    Then I should see "1 Found"
    
    
  Scenario: Search for some more different works from universal search box
    Given I have loaded the fixtures
      And the Sphinx indexes are updated
    When I am on the homepage
      And I fill in "site_search" with "words: >100 language:english"
      And I press "Search"
    Then I should see "1 Found"
    When I follow "Advanced search"
    Then I should be on the advanced search page
    When I fill in "refine_word_count" with ""
      And I fill in "refine_revised_at" with "> 2 years ago"
      And I press "Search works"
    Then I should see "1 Found"
    When I follow "Advanced search"
    Then I should be on the advanced search page
    When I fill in "refine_word_count" with "<1000"
      And I press "Search works"
    Then I should see "0 Found"
    When I am on the advanced search page
      And I fill in "refine_word_count" with "<10,000"
      And I fill in "refine_hit_count" with "> 1.000"
      And I press "Search works"
    Then I should see "1 Found"
      And I should see "First work"
