@series
Feature: Locked and partially locked series
  In order to keep my works under the radar
  As a registered archive user
  I should be able to make my serial works visible only to other registered users

Scenario: Post a series with a restricted work, then add a draft, then make the draft public and post it
    Given I am logged in as "fandomer" with password "password"
      And basic tags
      And I go to the new work page
      And I select "Not Rated" from "Rating"
      And I check "No Archive Warnings Apply"
      And I fill in "Fandoms" with "Supernatural"
      And I fill in "Characters" with "Sammy"
      And I fill in "Work Title" with "Humbug"
      And I fill in "content" with "The story of how they met and how they got into trouble"
      And I check "work_restricted"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "Antiholidays"
    And I press "Preview"
  Then I should see "Draft was successfully created."
    And I should see "Part 1 of the Antiholidays series"
  When I press "Post"
    And I go to fandomer's series page
  Then I should see "Antiholidays"
  When I am logged out
   And I go to fandomer's series page
  Then I should not see "Antiholidays"
  When I am logged in as "reccer" with password "password"
    And I go to fandomer's series page
  Then I should see "Antiholidays"
  When I view the series "Antiholidays"
  Then I should see "Humbug"
  When I am logged out
    And I am logged in as "fandomer" with password "password"
    And I go to the new work page
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "Supernatural"
    And I fill in "Work Title" with "Antivalentine"
    And I fill in "content" with "The not-love-story of how they met and how they got into trouble"
    And I check "work_restricted"
    And I check "series-options-show"
    And I select "Antiholidays" from "work_series_attributes_id"
    And I press "Preview"
  Then I should see "Draft was successfully created."
    And I should see "Part 2 of the Antiholidays series"
  When I view the series "Antiholidays"
  Then I should see "Works included: 1"
    And I should not see "Antivalentine"
  When I view the work "Humbug"
  Then I should not see "»" within "dd"
  When I edit the work "Antivalentine"
    And I uncheck "work_restricted"
    And I press "Preview"
  Then I should see "Part 2 of the Antiholidays series"
  When I press "Post"
  Then I should see "Part 2 of the Antiholidays series"
    And I should not see the "title" text "Restricted"
    And I should see "«" within "dd.series"
  When I am logged out
    And I view the series "Antiholidays"
  Then I should see "Antivalentine"
    But I should not see "Humbug"
  When I view the work "Antivalentine"
  Then I should see "Part 1 of the Antiholidays series"
    And I should not see "»" within "dd"
  When I am logged in as "reccer" with password "password"
    And I go to fandomer's series page
  Then I should see "Antiholidays"
  When I view the series "Antiholidays"
  Then I should see "Works included: 2"
    And I should see "Humbug"
    And I should see "Antivalentine"

  Scenario: edit a locked work to add it to a series
    Given I am logged in as "fandomer" with password "password"
      And basic tags
      And I post the locked work "Boohoo"
    When I edit the work "Boohoo"
      And I uncheck "work_restricted"
      And I check "front-notes-options-show"
      And I fill in "work_notes" with "Humbugness!"
      And I check "series-options-show"
      And I fill in "work_series_attributes_title" with "Antiholidays"
      And I press "Preview"
    Then I should see "Preview"
      And I should see "Part 1 of the Antiholidays series"
    When I press "Update"
    Then I should see "Work was successfully updated"
