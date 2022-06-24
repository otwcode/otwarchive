Feature: Hiding users and their content from search engines
  Scenario: Hidden users' user pages are disallowed for search engine indexing
    Given I have no users
      And the user "hidden" exists and is activated
      And the user "hidden" is hidden from search engines
    When I go to hidden's user page
    Then I should see a "meta" tag with "name" of "robots" and "content" of "noindex"
      And I should see a "meta" tag with "name" of "googlebot" and "content" of "noindex"

  Scenario: Unhidden users' user pages are allowed for search engine indexing
    Given I have no users
      And the user "unhidden" exists and is activated
    When I go to unhidden's user page
    Then I should not see a "meta" tag with "name" of "robots" and "content" of "noindex"
      And I should not see a "meta" tag with "name" of "googlebot" and "content" of "noindex"

  Scenario: Hidden users' works pages are disallowed for search engine indexing
    Given I have no users
      And the user "hidden" exists and is activated
      And the user "hidden" is hidden from search engines
      And the work "Hidden Work" by "hidden"
    When I view the work "Hidden Work"
    Then I should see a "meta" tag with "name" of "robots" and "content" of "noindex"
      And I should see a "meta" tag with "name" of "googlebot" and "content" of "noindex"

  Scenario: Unhidden users' works pages are allowed for search engine indexing
    Given I have no users
      And the user "unhidden" exists and is activated
      And the work "Unhidden Work" by "unhidden"
    When I view the work "Unhidden Work"
    Then I should not see a "meta" tag with "name" of "robots" and "content" of "noindex"
      And I should not see a "meta" tag with "name" of "googlebot" and "content" of "noindex"

  Scenario: Hidden users' series pages are disallowed for search engine indexing
    Given I am logged in as "hidden"
      And the user "hidden" is hidden from search engines
      And I post the work "Hidden Work" as part of a series "Hidden Series"
    When I am logged out
      And I view the series "Hidden Series"
    Then I should see a "meta" tag with "name" of "robots" and "content" of "noindex"
      And I should see a "meta" tag with "name" of "googlebot" and "content" of "noindex"

  Scenario: Unhidden users' series pages are allowed for search engine indexing
    Given I am logged in as "unhidden"
      And I post the work "Unhidden Work" as part of a series "Unhidden Series"
    When I am logged out
      And I view the series "Unhidden Series"
    Then I should not see a "meta" tag with "name" of "robots" and "content" of "noindex"
      And I should not see a "meta" tag with "name" of "googlebot" and "content" of "noindex"
