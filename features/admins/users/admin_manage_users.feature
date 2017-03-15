@admin
Feature: Admin Actions to manage users
  In order to manage user accounts
  As an an admin
  I want to be able to edit individual users

  Scenario: Admin can update a user's email address and roles
    Given the following activated user exists
      | login | password    |
      | dizmo | wrangulator |
    And I have loaded the "roles" fixture
    When I am logged in as an admin
    And I fill in "query" with "dizmo"
    And I press "Find"
    Then I should see "dizmo" within "#admin_users_table"

    # change user email
    When I fill in "user_email" with "dizmo@fake.com"
      And I press "Update"
    Then the "user_email" field should contain "dizmo@fake.com"

    # Adding and removing roles
    When I check "user_roles_1"
      And I press "Update"
    # Then show me the html
    Then I should see "User was successfully updated"
      And the "user_roles_1" checkbox should be checked
    When I uncheck "user_roles_1"
      And I press "Update"
    Then I should see "User was successfully updated"
      And the "user_roles_1" checkbox should not be checked

  Scenario: Troubleshooting a user displays a message
    Given the user "mrparis" exists and is activated
      And I am logged in as an admin
    When I go to the abuse administration page for "mrparis"
      And I follow "Troubleshoot Account"
    Then I should see "User account troubleshooting complete."

  Scenario: A admin can activate a user account
    Given the user "mrparis" exists and is not activated
      And I am logged in as an admin
    When I go to the abuse administration page for "mrparis"
      And I press "Activate User Account"
    Then I should see "User Account Activated"
      And the user "mrparis" should be activated

  Scenario: A admin can send an activation email for a user account
    Given the following users exist
      | login  | password  | email                | activation_code |
      | torres | something | torres@starfleet.org | fake_code       |
      And I am logged in as an admin
      And all emails have been delivered
    When I go to the abuse administration page for "torres"
      And I press "Send Activation Email"
    Then I should see "Activation email sent"
      And 1 email should be delivered to "torres"
