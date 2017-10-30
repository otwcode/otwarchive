Feature: Admin Find Users page

  Background:
    Given I have loaded the "roles" fixture
      And the following activated users exist
        | login  | email      |
        | usera  | a@ao3.org  |
        | userb  | b@bo3.org  |
        | usercb | cb@bo3.org |
      And the user "userb" exists and has the role "archivist"
      And I am logged in as an admin

  Scenario: The default page for the Admin section should be the Find Users page
    Then I should see "Find Users"

  Scenario: The Find Users page should perform a partial match on name
    When I fill in "query" with "user"
      And I submit
    Then I should see "usera"
      And I should see "userb"
      And I should see "usercb"

  Scenario: The Find Users page should perform a partial match by email
    When I fill in "query" with "bo3"
      And I submit
    Then I should see "userb"
      And I should see "usercb"
      But I should not see "usera"

  Scenario: The Find Users page should perform an exact match by role
    When I select "Archivist" from "role"
      And I submit
    Then I should see "userb"
      But I should not see "usera"
      And I should not see "usercb"

  Scenario: The Find Users should display an appropriate message if no users are found
    When I fill in "query" with "co3"
      And I submit
    Then I should see "0 users found"

  # Bulk email search
  Scenario: The Bulk Email Search page should find all existing matching users
    When I go to the Bulk Email Search page
      And I fill in "Email addresses *" with
      """
        b@bo3.org
        a@ao3.org
      """
      And I press "Find"
    Then I should see "userb"
      And I should see "usera"
      But I should not see "usercb"

  Scenario: The Bulk Email Search page should list emails found and not found
    When I go to the Bulk Email Search page
      And I fill in "Email addresses *" with
      """
        b@bo3.org
        a@ao3.org
        c@co3.org
      """
      And I press "Find"
    Then I should see "2 found"
      And I should see "1 not found"

  Scenario: The Bulk Email Search page should find an exact match
    When I go to the Bulk Email Search page
      And I fill in "Email addresses *" with "b@bo3.org"
      And I press "Find"
    Then I should see "userb"
      But I should not see "usera"
      And I should not see "usercb"

   Scenario: Admins can download a CSV of found emails
     When I go to the Bulk Email Search page
      And I fill in "Email addresses *" with
      """
        b@bo3.org
        a@ao3.org
        c@co3.org
      """
      And I press "Download CSV"
     Then I should download a csv file with 4 rows and the header row "Email Username"
