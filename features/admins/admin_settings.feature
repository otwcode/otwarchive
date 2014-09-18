@admin
Feature: Admin Settings Page
  In order to improve performance
  As an admin
  I want to be able to control guest downloading and tag wrangling.

  Scenario: Settings page shows options for guest downloading and tag wrangling
    Given I am logged in as an admin
    When I go to the admin-settings page
    Then I should see "Turn off downloading for guests"
      And I should see "Turn off tag wrangling for non-admins"

  Scenario: Update tag wrangling and guest downloading
    Given I am logged in as an admin
    When I go to the admin-settings page
      And I check "Turn off downloading for guests"
      And I check "Turn off tag wrangling for non-admins"
      And I press "Update"
    Then I should see "Archive settings were successfully updated."

  Scenario: Turn off guest downloading
    Given guest downloading is off
      And I have a work "Storytime"
    When I log out
      And I view the work "Storytime"
      And I follow "MOBI"
    Then I should see "Due to current high load"

  Scenario: Turn off tag wrangling
    Given tag wrangling is off
      And the following activated tag wrangler exists
        | login           |
        | dizmo           |
      And a character exists with name: "Ianto Jones", canonical: true    
    When I am logged in as "dizmo"
      And I edit the tag "Ianto Jones"
    Then I should see "Wrangling is disabled at the moment. Please check back later."
      And I should not see "Synonym of"