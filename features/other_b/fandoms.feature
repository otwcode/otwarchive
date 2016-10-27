@fandoms
Feature: There is a list of unassigned Fandoms

  Scenario: A user can see the list of fandoms and filter it

    Given I have a canonical "TV Shows" fandom tag named "Steven Universe"
      And I have a canonical "Movies" fandom tag named "High School Musical"
      And I am logged in as "author"
      And I post the work "Stronger than you" with fandom "Steven Universe"
      And I post the work "Breaking free" with fandom "High School Musical"
      And I am logged in as a tag wrangler
    When I go to the unassigned fandoms page
    Then I should see "Steven Universe"
      And I should see "High School Musical"
    When I select "TV Shows" from "media_id"
      And I press "Sort and Filter"
    Then I should see "Steven Universe"
      And I should not see "High School Musical"
    When I select "Movies" from "media_id"
      And I press "Sort and Filter"
    Then I should see "High School Musical"
    When I follow "High School Musical"
    Then I should see "This tag belongs to the Fandom Category."
