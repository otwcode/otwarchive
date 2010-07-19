@series
Feature: Edit Series

  Scenario: Three ways to add a work to a series
    Given the following activated user exists
      | login         | password   |
      | author        | password   |
      And a warning exists with name: "Choose Not To Use Archive Warnings", canonical: true
    When I am logged in as "author" with password "password"
      And I go to the new work page
      And I select "Not Rated" from "Rating"
      And I check "Choose Not To Use Archive Warnings"
      And I fill in "Fandoms" with "My Little Pony"
      And I fill in "work_series_attributes_title" with "Ponies"
      And I fill in "Work Title" with "Sweetie Belle"
      And I fill in "content" with "First little pony is all alone"
      And I press "Preview"
    Then I should see "Part 1 of the Ponies series"
    When I press "Post"
    When I view the series "Ponies"
    Then I should see "Sweetie Belle"
    When I go to the new work page
      And I select "Not Rated" from "Rating"
      And I check "Choose Not To Use Archive Warnings"
      And I fill in "Fandoms" with "My Little Pony"
      And I select "Ponies" from "work_series_attributes_id"
      And I fill in "Work Title" with "Starsong"
      And I fill in "content" with "Second little pony want to make friends"
      And I press "Preview"
    Then I should see "Part 2 of the Ponies series"
    When I press "Post"
      And I view the series "Ponies"
    Then I should see "Sweetie Belle"
      And I should see "Starsong"
    When I go to the new work page
      And I select "Not Rated" from "Rating"
      And I check "Choose Not To Use Archive Warnings"
      And I fill in "Fandoms" with "My Little Pony"
      And I fill in "Work Title" with "Rainbow Dash"
      And I fill in "content" with "Third little pony is a little shy"
      And I press "Preview"
      And I press "Post"
    When I view the series "Ponies"
      Then I should not see "Rainbow Dash"
    When I edit the work "Rainbow Dash"
      And I select "Ponies" from "work_series_attributes_id"
      And I press "Preview"
      And I press "Update"
   When I view the series "Ponies"
     When I follow "Rainbow Dash"
    Then I should see "Part 3 of the Ponies series"
    When I follow "«"
    Then I should see "Starsong"
    When I follow "«"
    Then I should see "Sweetie Belle"
    When I follow "»"
    Then I should see "Starsong"
