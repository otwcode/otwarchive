@works
Feature: Search Works
  In order to test search
  As a humble coder
  I have to use cucumber with thinking sphinx

  # do everything that doesn't modify the works in one scenario 
  # so you only have to load the fixtures and update the sphinx indexes once
  Scenario: Search works from univeral search box
    Given I have loaded the fixtures
      And the Sphinx indexes are updated
    When I am on the homepage
      And I fill in "site_search" with "(title,summary): second words: >100"
      And I press "Search"
    Then I should see "Text: (title,summary): second"
      And I should see "Words: >100"
      And I should see "2 Found"
      And I should not see "First work"
      And I should see "second work"
      And I should see "third work"
      And I should not see "fourth"
    When I am on the homepage
      And I fill in "site_search" with "first"
      And I press "Search"
    Then I should see "3 Found"
    When I follow "Advanced search"
    Then I should be on the search page
    When I fill in "refine_text" with ""
      And I fill in "refine_tag" with "second"
      And I press "Search works"
    Then I should see "1 Found"
    When I am on the search page
      And I fill in "refine_language" with "Deutsch"
      And I press "Search works"
    Then I should see "1 Found"
    When I am on the homepage
      And I fill in "site_search" with "hits: >10"
      And I press "Search"
    Then I should see "2 Found"
    When I follow "Advanced search"
    Then I should be on the search page
    When I fill in "refine_hit_count" with "10000-20000"
      And I press "Search works"
    Then I should see "1 Found"
    When I am on the homepage
      And I fill in "site_search" with "words: >100 language:english"
      And I press "Search"
    Then I should see "1 Found"
    When I follow "Advanced search"
    Then I should be on the search page
    When I fill in "refine_word_count" with ""
      And I fill in "refine_revised_at" with "> 2 years ago"
      And I press "Search works"
    Then I should see "1 Found"
    When I follow "Advanced search"
    Then I should be on the search page
    When I fill in "refine_word_count" with "<1000"
      And I press "Search works"
    Then I should see "0 Found"
    When I am on the search page
      And I fill in "refine_word_count" with "<10,000"
      And I fill in "refine_hit_count" with "> 1.000"
      And I press "Search works"
    Then I should see "1 Found"
      And I should see "First work"
