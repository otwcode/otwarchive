@series
Feature: Rearrange works within a series
  In order to manage parts of a series
  As a humble series writer
  I want to be able to reorder the parts of my series

  Scenario: Rearrange parts of a series.
    Given the following activated user exists
      | login         | password   |
      | author        | password   |
      And basic tags
    When I am logged in as "author" with password "password"
      And I go to the new work page
      And I select "Not Rated" from "Rating"
      And I check "No Archive Warnings Apply"
      And I fill in "Fandoms" with "Supernatural"
      And I fill in "Work Title" with "A Bad, Bad Day"
      And I fill in "work_series_attributes_title" with "Tale of Woe"
      And I fill in "content" with "It was a very bad day for the brothers."
      And I press "Preview"
    Then I should see "Part 1 of the Tale of Woe series"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I view the series "Tale of Woe"
    Then I should see "A Bad, Bad Day"
    When I go to the new work page
      And I select "Not Rated" from "Rating"
      And I check "No Archive Warnings Apply"
      And I fill in "Fandoms" with "Supernatural"
      And I select "Tale of Woe" from "work_series_attributes_id"
      And I fill in "Work Title" with "A Bad, Bad Night"
      And I fill in "content" with "It was a very bad night for the brothers."
      And I press "Preview"
    Then I should see "Part 2 of the Tale of Woe series"
    When I press "Post"
    Then I follow "New Work"
      And I select "Not Rated" from "Rating"
      And I check "No Archive Warnings Apply"
      And I fill in "Fandoms" with "Supernatural"
      And I select "Tale of Woe" from "work_series_attributes_id"
      And I fill in "Work Title" with "Things Get Worse"
      And I fill in "content" with "More bad stuff happens."
      And I press "Preview"
      And I press "Post"
    Then I should see "Part 3 of the Tale of Woe series"
    When I view the series "Tale of Woe"
      And I follow "Reorder Series"
    Then I should see "Manage Series: Tale of Woe"
      And I should see "1. A Bad, Bad Day"
      And I should see "2. A Bad, Bad Night"
      And I should see "3. Things Get Worse"
    When I fill in "serial_0" with "3"
      And I fill in "serial_1" with "1"
      And I fill in "serial_2" with "2"
      And I press "Update Positions"
    Then I should see "Series order has been successfully updated"
    When I follow "Reorder Series"
      And I should see "1. A Bad, Bad Night"
      And I should see "2. Things Get Worse"
      And I should see "3. A Bad, Bad Day"


