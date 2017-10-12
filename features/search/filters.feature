@users
Feature: Filters
  In order to ensure filtering works on works and bookmarks
  As a humble user
  I want to filter on a user's works and bookmarks

  Background:
    Given a fandom exists with name: "The Hobbit", canonical: true
      And a fandom exists with name: "Harry Potter", canonical: true
      And a fandom exists with name: "Legend of Korra", canonical: true
      And I am logged in as "meatloaf"
      And meatloaf can use the new search
      And I post the work "A Hobbit's Meandering" with fandom "The Hobbit"
      And I post the work "Bilbo Does the Thing" with fandom "The Hobbit, Legend of Korra"
      And I post the work "Roonal Woozlib and the Ferrets of Nimh" with fandom "Harry Potter"

  @javascript
  Scenario: You can filter through a user's works using inclusion filters
    When I go to meatloaf's user page
      And I follow "Works (3)"
    Then I should see "A Hobbit's Meandering"
      And I should see "Bilbo Does the Thing"
      And I should see "Roonal Woozlib and the Ferrets of Nimh"
      And I should see "Include"
      And I should see "Exclude"
    When I press "Fandoms" within "dd.include"
    Then I should see "The Hobbit (2)" within "#include_fandom_tags"
      And I should see "Harry Potter (1)" within "#include_fandom_tags"
      And I should see "Legend of Korra (1)" within "#include_fandom_tags"
    When I check "The Hobbit (2)" within "#include_fandom_tags"
      And I press "Sort and Filter"
    Then I should see "A Hobbit's Meandering"
      And I should see "Bilbo Does the Thing"
      And I should not see "Roonal Woozlib and the Ferrets of Nimh"
    When I press "Fandoms" within "dd.include"
    Then I should see "The Hobbit (2)" within "#include_fandom_tags"
      And I should see "Legend of Korra (1)" within "#include_fandom_tags"
      And I should see "Harry Potter (1)" within "#include_fandom_tags"
    When I check "Legend of Korra (1)" within "#include_fandom_tags"
      And press "Sort and Filter"
    Then I should see "Bilbo Does the Thing"
      And I should not see "A Hobbit's Meandering"
      And I should not see "Roonal Woozlib and the Ferrets of Nimh"
    When I press "Fandoms" within "dd.include"
      And I uncheck "The Hobbit (2)" within "#include_fandom_tags"
      And I uncheck "Legend of Korra (1)" within "#include_fandom_tags"
      And I press "Sort and Filter"
    Then I should see "Roonal Woozlib and the Ferrets of Nimh"
      And I should see "A Hobbit's Meandering"
      And I should see "Bilbo Does the Thing"

  @javascript
  Scenario: You can filter through a user's works using exclusion filters
    When I go to meatloaf's user page
      And I follow "Works (3)"
    When I press "Fandoms" within "dd.exclude"
    Then I should see "The Hobbit (2)" within "#exclude_fandom_tags"
      And I should see "Harry Potter (1)" within "#exclude_fandom_tags"
      And I should see "Legend of Korra (1)" within "#exclude_fandom_tags"
    When I check "Harry Potter (1)" within "#exclude_fandom_tags"
      And I press "Sort and Filter"
    Then I should see "Bilbo Does the Thing"
      And I should see "A Hobbit's Meandering"
      And I should not see "Roonal Woozlib and the Ferrets of Nimh"
    When I press "Fandoms" within "dd.exclude"
    Then I should see "The Hobbit (2)" within "#exclude_fandom_tags"
      And I should see "Legend of Korra (1)" within "#exclude_fandom_tags"
      And I should see "Harry Potter (1)" within "#exclude_fandom_tags"
    When I check "Legend of Korra (1)" within "#exclude_fandom_tags"
      And I press "Sort and Filter"
    Then I should see "A Hobbit's Meandering"
      And I should not see "Bilbo Does the Thing"
      And I should not see "Roonal Woozlib and the Ferrets of Nimh"

  @javascript
  Scenario: You can filter through a user's bookmarks using inclusion filters
    Given I am logged in as "recengine"
      And I bookmark the work "Bilbo Does the Thing"
      And I bookmark the work "A Hobbit's Meandering"
      And I bookmark the work "Roonal Woozlib and the Ferrets of Nimh"
    When I go to recengine's user page
      And I follow "Bookmarks (3)"
    Then I should see "Bilbo Does the Thing"
      And I should see "A Hobbit's Meandering"
      And I should see "Roonal Woozlib and the Ferrets of Nimh"
      And I should see "Include"
      And I should see "Exclude"
    When I press "Fandoms" within "dd.include"
    Then I should see "The Hobbit (2)" within "#include_fandom_tags"
      And I should see "Harry Potter (1)" within "#include_fandom_tags"
      And I should see "Legend of Korra (1)" within "#include_fandom_tags"
    When I check "The Hobbit (2)" within "#include_fandom_tags"
      And I press "Sort and Filter"
    Then I should see "A Hobbit's Meandering"
      And I should see "Bilbo Does the Thing"
      And I should not see "Roonal Woozlib and the Ferrets of Nimh"
    When I press "Fandoms" within "dd.include"
    Then I should see "The Hobbit (2)" within "#include_fandom_tags"
      And I should see "Legend of Korra (1)" within "#include_fandom_tags"
      And I should see "Harry Potter (1)" within "#include_fandom_tags"
    When I check "Legend of Korra (1)" within "#include_fandom_tags"
      And press "Sort and Filter"
    Then I should see "Bilbo Does the Thing"
      And I should not see "A Hobbit's Meandering"
      And I should not see "Roonal Woozlib and the Ferrets of Nimh"

  @javascript
  Scenario: You can filter through a user's bookmarks using exclusion filters
    Given I am logged in as "recengine"
      And I bookmark the work "Bilbo Does the Thing"
      And I bookmark the work "A Hobbit's Meandering"
      And I bookmark the work "Roonal Woozlib and the Ferrets of Nimh"
    When I go to recengine's user page
      And I follow "Bookmarks (3)"
    When I press "Fandoms" within "dd.exclude"
    Then the "The Hobbit (2)" checkbox within "#exclude_fandom_tags" should not be checked
      And the "Harry Potter (1)" checkbox within "#exclude_fandom_tags" should not be checked
      And the "Legend of Korra (1)" checkbox within "#exclude_fandom_tags" should not be checked
    When I check "Harry Potter (1)" within "#exclude_fandom_tags"
      And I press "Sort and Filter"
    Then I should see "Bilbo Does the Thing"
      And I should see "A Hobbit's Meandering"
      And I should not see "Roonal Woozlib and the Ferrets of Nimh"
    When I press "Fandoms" within "dd.exclude"
    Then the "The Hobbit (2)" checkbox within "#exclude_fandom_tags" should not be checked
      And the "Legend of Korra (1)" checkbox within "#exclude_fandom_tags" should not be checked
      And the "Harry Potter (1)" checkbox within "#exclude_fandom_tags" should be checked
    When I check "Legend of Korra (1)" within "#exclude_fandom_tags"
      And I press "Sort and Filter"
    Then I should see "A Hobbit's Meandering"
      And I should not see "Bilbo Does the Thing"
      And I should not see "Roonal Woozlib and the Ferrets of Nimh"
