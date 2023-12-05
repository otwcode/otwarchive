Feature: Admin Find Users page

  Background:
    Given I have loaded the "roles" fixture
      And the following activated users exist
        | login  | email      |
        | userA  | a@ao3.org  |
        | userB  | b@bo3.org  |
        | userCB | cb@bo3.org |
      And the user "userB" exists and has the role "archivist"
      And I am logged in as a super admin
      And I go to the manage users page

  Scenario: The Find Users page performs a partial match on name with * wildcard
    When I fill in "Name" with "u*er*"
      And I submit
    Then I should see "userA"
      And I should see "userB"
      And I should see "userCB"

  Scenario: The Find Users page performs a exact match on name by default
    When I fill in "Name" with "user"
      And I submit
    Then I should see "0 users found"
    When I fill in "Name" with "userA"
      And I submit
    Then the field labeled "user_email" should contain "a@ao3.org"
      But I should not see "UserB"

  Scenario: The Find Users page searches past logins only if the option is selected
    When I am logged in as "userA"
      And I visit the change username page for userA
      And I fill in "New user name" with "userD"
      And I fill in "Password" with "password"
      And I press "Change"
    Then I should get confirmation that I changed my username
    When I am logged in as a "support" admin
      And I go to the manage users page
      And I fill in "Name" with "userA"
      And I submit
    Then I should see "0 users found"
    When I check "Include past usernames and emails"
      And I submit
    Then I should see "1 user found"
      And I should see "userD"

  Scenario: The Find Users page performs a partial match by email with * wildcard
    When I fill in "Email" with "*bo3*"
      And I submit
    Then I should see "userB"
      And I should see "userCB"
      But I should not see "userA"

  Scenario: The Find Users page performs a exact match on email by default
    When I fill in "Email" with "ao3"
      And I submit
    Then I should see "0 users found"
    When I fill in "Email" with "a@ao3.org"
      And I submit
    Then I should see "userA"
      But I should not see "UserB"

  Scenario: The Find Users page searches past emails if the option is selected
    When I am logged in as "userA"
      And I visit the change email page for userA
      And I fill in "New Email" with "d@ao3.org"
      And I fill in "Confirm New Email" with "d@ao3.org"
      And I fill in "Password" with "password"
      And I press "Change"
    Then I should get confirmation that I changed my email
    Given I am logged in as a "policy_and_abuse" admin
      And I go to the manage users page
      And I fill in "Email" with "a@ao3.org"
      And I submit
    Then I should see "0 users found"
    When I check "Include past usernames and emails"
      And I submit
    Then I should see "1 user found"
      And I should see "userA"
      And the field labeled "user_email" should contain "d@ao3.org"

  Scenario: The Find Users page performs an exact match by role
    When I select "Archivist" from "Role"
      And I submit
    Then I should see "userB"
      But I should not see "userA"
      And I should not see "userCB"

  Scenario: The Find Users page performs an exact match by ID in addition to any other criteria
    When the search criteria contains the ID for "userB"
      And I submit
    Then I should see "1 user found"
      And I should see "userB"
      But I should not see "userA"
      And I should not see "userCB"
    When I fill in "Name" with "*A"
      And I submit
    Then I should see "0 users found"
    When I fill in "Name" with "*B"
      And I submit
    Then I should see "1 user found"
      And I should see "userB"

  # Bulk email search
  Scenario: The Bulk Email Search page finds all existing matching users
    When I go to the Bulk Email Search page
      And I fill in "Email addresses *" with
      """
        b@bo3.org
        a@ao3.org
      """
      And I press "Find"
    Then I should see "userB"
      And I should see "userA"
      But I should not see "userCB"
      And I should not see "Not found"

  Scenario: The Bulk Email Search page lists emails found, not found and duplicates
    When I go to the Bulk Email Search page
      And I fill in "Email addresses *" with
      """
        b@bo3.org
        a@ao3.org
        c@co3.org
        C@CO3.org
      """
      And I press "Find"
    Then I should see "2 found"
      And I should see "1 not found"
      And I should see "1 duplicate"
      And I should see "Not found"

  Scenario: The Bulk Email Search page finds an exact match
    When I go to the Bulk Email Search page
      And I fill in "Email addresses *" with "b@bo3.org"
      And I press "Find"
    Then I should see "userB"
      But I should not see "userA"
      And I should not see "userCB"
      And I should not see "Not found"

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
